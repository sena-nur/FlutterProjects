import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({
    Key? key,
  }) : super(key: key);

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final CardSwiperController controller = CardSwiperController();
  List<ExampleCandidateModel> candidates = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    setState(() {
      _isLoading = true;
    });

    candidates.clear();

    Position position = await _determinePosition();

    if (position != null) {
      final apiKey = 'AIzaSyC6-1byZsRdCHVXnTDP9pjvmFRuV_kuZAk';
      final radius = 3000;
      List<ExampleCandidateModel> allCandidates = [];

      for (var placeX in ["museum", "point_of_interest", "historical_site"]) {
        final url =
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=$radius&type=$placeX&key=$apiKey';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> places = data['results'];

          List<ExampleCandidateModel> candidatesForPlaceX = places.map((place) {
            return ExampleCandidateModel(
              placeName: place['name'],
              placePhoto: place['photos'] != null && place['photos'].isNotEmpty ? place['photos'][0]['photo_reference'] : '',
              placeRating: place['rating'] != null ? place['rating'].toDouble() : 0.0,
              API: apiKey,
            );
          }).toList();

          allCandidates.addAll(candidatesForPlaceX);
        } else {
          throw Exception('Failed to load nearby places');
        }
      }

      setState(() {
        candidates = allCandidates;
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri etkin değil.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni verilmedi.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void _addToFavorites(ExampleCandidateModel candidate) {
    final databaseReference = FirebaseDatabase.instance.reference().child('favorites');

    try {
      databaseReference.push().set({
        'placeName': candidate.placeName,
        'placePhoto': candidate.placePhoto,
        'placeRating': candidate.placeRating,
      });
    } catch (e) {
      print('Error saving to Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Swipe!'),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            Flexible(
              child: candidates.isNotEmpty
                  ? CardSwiper(
                controller: controller,
                cardsCount: candidates.length,
                cardBuilder: (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                    ) {
                  return ExampleCard(
                    candidate: candidates[index],
                    onSwipeRight: () => _addToFavorites(candidates[index]),
                  );
                },
              )
                  : Center(
                child: Text("No place found near you."),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: controller.undo,
                    child: const Icon(Icons.rotate_left),
                  ),
                  FloatingActionButton(
                    onPressed: () => controller.swipe(CardSwiperDirection.left),
                    child: const Icon(Icons.keyboard_arrow_left),
                  ),
                  FloatingActionButton(
                    onPressed: () => controller.swipe(CardSwiperDirection.right),
                    child: const Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleCandidateModel {
  final String placeName;
  final double placeRating;
  final String placePhoto;
  final String API;

  ExampleCandidateModel({
    required this.placeName,
    required this.placePhoto,
    required this.placeRating,
    required this.API,
  });
}

class ExampleCard extends StatelessWidget {
  final ExampleCandidateModel candidate;
  final VoidCallback onSwipeRight;

  const ExampleCard({
    required this.candidate,
    required this.onSwipeRight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          onSwipeRight();
        }
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: candidate.placePhoto.isNotEmpty
                  ? Image.network(
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${candidate.placePhoto}&key=${candidate.API}',
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/icon-image-not-found-free-vector.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.placeName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rating: ${candidate.placeRating}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
