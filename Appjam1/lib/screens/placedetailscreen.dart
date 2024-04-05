import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final String placeName;
  final double placeRating;
  final String placePhoto;
  final String placeId;
  final String API;
  final String defaultPhotoURL; // Varsayılan fotoğraf URL'si

  const PlaceDetailsScreen({
    Key? key,
    required this.placeName,
    required this.placePhoto,
    required this.placeRating,
    required this.API,
    required this.defaultPhotoURL,
    required this.placeId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$API'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> reviews = data['result']['reviews'];
      List<Map<String, dynamic>> formattedReviews = [];
      for (var review in reviews) {
        formattedReviews.add({
          'author': review['author_name'],
          'rating': review['rating'],
          'text': review['text'],
        });
      }
      return formattedReviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int numOfFullStars = rating.floor();
    double remainder = rating - numOfFullStars;

    // Add full stars
    for (int i = 0; i < numOfFullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.purpleAccent));
    }

    // Add half star if remainder is greater than 0
    if (remainder > 0) {
      stars.add(Icon(Icons.star_half, color: Colors.purpleAccent));
    }

    // Add empty stars
    int numOfEmptyStars = 5 - numOfFullStars - (remainder > 0 ? 1 : 0);
    for (int i = 0; i < numOfEmptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: Colors.purpleAccent));
    }

    return Row(
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffbaeaea),
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Body'nin her yanına padding ekleyelim
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 300, // Fotoğrafın yüksekliği
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: FutureBuilder<http.Response>(
                      future: http.get(Uri.parse(
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$placePhoto&key=$API')),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Container(); // Hata durumunda boş container döndür
                          }
                          if (snapshot.data!.statusCode == 200) {
                            // Fotoğraf başarıyla alındıysa
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(snapshot.data!.bodyBytes), // Fotoğrafı göster
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            // Fotoğraf alınamadı
                            return Container(); // Hata durumunda boş container döndür
                          }
                        } else {
                          // İstek tamamlanmadıysa veya bekleniyorsa
                          return Center(
                            child: CircularProgressIndicator(), // İlerleme çemberi göster
                          );
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    '$placeName\nRating: $placeRating',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),

                ),
                ElevatedButton(
                  onPressed: () async {
                    final url = 'https://www.google.com/maps/dir/?api=1&destination=place_name:$placeName';
                    print(url); // URL'yi kontrol etmek için ekrana yazdırma
                    try {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not launch Google Maps'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                        ),
                      );
                    }
                  },
                  child: Text('Lets Go'),
                ),


                SizedBox(height: 20),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchReviews(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                      return Center(
                        child: Container(
                          color: Colors.black12, // Yorum bloğunun arka plan rengi
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'Henüz hiçbir yorum yapılmamış',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }

                    else if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          for (var review in snapshot.data!)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15), // Kenarları oval yap
                                color: Colors.black12, // Yorum bloğunun arka plan rengi
                              ), // Yorum bloğunun arka plan rengi
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Author: ${review['author']}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis, // Yazar adının taşma durumunda kesilmesi
                                        ),
                                      ),
                                      _buildStarRating(review['rating'].toDouble()),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    review['text'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),

              ],
            ),
          ),
        ),
      ),
      // Sol tarafta geri dönüş işlevselliği eklemek için GestureDetector widget'ını kullanıyoruz

    );
  }
}