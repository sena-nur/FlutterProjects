import 'dart:convert';
import 'dart:math';
import 'package:appjam_1/screens/placedetailscreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String defaultPhotoUrl = "https://th.bing.com/th/id/R.6377be1a0e7f89adf0455272f3a3efb3?rik=uUVJ3fANCDOQ5w&riu=http%3a%2f%2fwww.clker.com%2fcliparts%2fB%2fu%2fS%2fl%2fW%2fl%2fno-photo-available-hi.png&ehk=Sq1dq%2fPCrzkDhyZbWx77pSCNCb%2bRVbxFHhVf8AD%2btvM%3d&risl=&pid=ImgRaw&r=0";
  String API_KEY = "AIzaSyC6-1byZsRdCHVXnTDP9pjvmFRuV_kuZAk";
  String place = "";
  double _distanceRange = 500;
  double _zoom = 14;
  GoogleMapController? _controller;
  static LatLng _currentPosition = const LatLng(0, 0);

  List<List<String>> _jsonDatas = [[], [], [], [], []];

  List<String> _types = [
    'restaurant',
    'cafe',
    'bar',
    'movie_theater',
    'supermarket',
    'park',
    'shopping_mall',
    'museum', // Müze türü eklendi
  ]; // Filtreleme için kullanılacak yer türleri
  String _selectedPlaceName = '';
  LatLng _selectedPlacePosition = LatLng(0, 0); // Seçilen yerin konumunu saklamak için

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisleri devre dışı.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izinleri reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Konum izinleri kalıcı olarak reddedildi, izin isteyemeyiz.');
    }

    Position position = await Geolocator.getCurrentPosition();
    _updateCurrentPosition(position);

    await _fetchNearbyPlaces("");
  }

  Future<void> _fetchNearbyPlaces(type) async {
    String typesQuery = "&types=" + type;


    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=$_distanceRange$typesQuery&key=$API_KEY'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      setState(() {

        _jsonDatas[0].clear();
        _jsonDatas[1].clear();
        _jsonDatas[2].clear();
        _jsonDatas[3].clear();
        var count = 0;

        for (var place in results) {
          String? photoReference;
          if (place["photos"] != null && place["photos"].length > 0) {
            photoReference = place["photos"][0]["photo_reference"];
          }
          if (photoReference != null) {
            _jsonDatas[3].add("$photoReference");
          } else {
            _jsonDatas[3].add("0");
          }
          count = count+1;
          _jsonDatas[0].add(count.toString());
          _jsonDatas[1].add(place['name']);
          _jsonDatas[2].add(place["rating"].toString());
          _jsonDatas[4].add(place["place_id"].toString());
        }

      });
    } else {
      throw Exception('Failed to load nearby places');
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeName) async {
    final response = await http.get(Uri.parse('https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$placeName&inputtype=textquery&fields=geometry&key=$API_KEY'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['candidates'].isNotEmpty) {
        return data['candidates'][0];
      } else {
        throw Exception('Failed to get place details');
      }
    } else {
      throw Exception('Failed to get place details');
    }
  }

  void _markPlaceOnMap(String placeName) async {
    var selectedPlaceDetails = await _getPlaceDetails(placeName);
    var placePosition = LatLng(selectedPlaceDetails['geometry']['location']['lat'], selectedPlaceDetails['geometry']['location']['lng']);
    _updateMapLocation(placePosition, 16, placeName);
  }

  void _updateCurrentPosition(Position position) {
    LatLng currentPosition = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = currentPosition;
    });

    if (_controller != null) {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: currentPosition,
        zoom: _zoom,
      )));
    }
  }

  void _updateMapLocation(LatLng targetPosition, double zoom, String placeName) {
    setState(() {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: targetPosition,
        zoom: _zoom,
      )));
      _selectedPlaceName = placeName;
      _selectedPlacePosition = targetPosition;
    });
  }

  Set<Marker> _createMarker() {
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId("currentLocation"),
        position: _currentPosition,
        infoWindow: InfoWindow(title: "Mevcut Konumunuz"),
      ),
    };

    if (_selectedPlaceName.isNotEmpty) {
      markers.add(
        Marker(
          markerId: MarkerId(_selectedPlaceName),
          position: _selectedPlacePosition,
          infoWindow: InfoWindow(title: _selectedPlaceName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Daire şeklinde mavi işaretleyici
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Current Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                if (_currentPosition.latitude != 0 && _currentPosition.longitude != 0) {
                  controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: _currentPosition,
                    zoom: _zoom,
                  )));
                }
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: _zoom,
              ),
              markers: _createMarker(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _types.map((type) {
                return FilterButton(
                  text: type.replaceAll('_', ' '),
                  onTap: () {
                    setState(() {
                      place = type;
                      _fetchNearbyPlaces(type);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Slider(
            value: _distanceRange,
            min: 300,
            max: 3000,
            divisions: 18,
            label: '$_distanceRange m', // Slider'ın üzerinde mesafe aralığını göster
            onChanged: (value) {
              setState(() {
                _distanceRange = value; // Slider'daki değeri güncelle
                _fetchNearbyPlaces(place); // Yeni mesafe aralığına göre yakındaki yerleri yeniden yükle
              });
            },
          ),
          Expanded(
            child: _jsonDatas[1].isNotEmpty
                ? ListView.builder(
              itemCount: _jsonDatas[1].length,

              itemBuilder: (context, index) {

                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      // Lokasyon ikonuna tıklanınca yapılacak işlemler
                      _markPlaceOnMap(_jsonDatas[1][index]);
                    },
                    child: Icon(Icons.location_on), // Lokasyon ikonu
                  ),
                  title: Text(_jsonDatas[1][index]),
                  trailing: GestureDetector(
                    onTap: () {
                      // Detay ikonuna tıklanınca yapılacak işlemler
                      // Örneğin detaylar için bir sayfaya yönlendirme yapabilirsiniz
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(placeName: _jsonDatas[1][index],placeRating:double.parse(_jsonDatas[2][index]) ,placePhoto: _jsonDatas[3][index],placeId:_jsonDatas[4][index], API:API_KEY, defaultPhotoURL: defaultPhotoUrl,),
                        ),
                      );
                    },
                    child: Icon(Icons.info), // Detay ikonu
                  ),
                );

              },
            )
                : Center(
              child: CircularProgressIndicator(),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _determinePosition();
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const FilterButton({
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
