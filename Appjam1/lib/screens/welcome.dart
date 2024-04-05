import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'giris_yap.dart';
import 'package:lottie/lottie.dart';

import 'kayit_ol.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6869af),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie.json'),
            const Text(
              'Lokal gezginlere hoşgeldin!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0), // Add some space
            const Text(
              'Bulunduğun şehirdeki restorantları, turistik yerleri ve daha fazlasını keşfet!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 50.0, // Set the height of the button
              width: MediaQuery.of(context).size.width *
                  0.6, // Set the width of the button to 60% of the screen width
              decoration: BoxDecoration(
                color: const Color(0xFF83d1d8), // Set the color of the button
                borderRadius:
                BorderRadius.circular(30.0), // Make the button circular
              ),
              child: TextButton(
                onPressed: () {
                  Get.to(() =>
                  const KayitOlScreen()); // Navigate to the GirisScreen when the button is pressed
                },
                child: const Text(
                  'Kayıt ol',
                  style: TextStyle(
                    color: Colors.white, // Set the color of the text
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                text: 'Bir hesabın var mı? ',
                children: <TextSpan>[
                  TextSpan(
                    text: 'Giriş yap',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(() =>
                        const GirisScreen()); // Navigate to the GirisScreen when the text is pressed
                      },
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