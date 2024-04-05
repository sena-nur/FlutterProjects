import 'package:appjam_1/screens/kayit_ol.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'main_menu.dart'; // Import Get library

class GirisScreen extends StatefulWidget {
  const GirisScreen({Key? key}) : super(key: key);

  @override
  GirisScreenState createState() => GirisScreenState();
}

class GirisScreenState extends State<GirisScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to the main menu after successful login using Get
      Get.to(() => const MainMenu());
      Get.snackbar(
          'Hoşgedin', // title
          'Başarılı bir şekilde giriş yaptınız!', // message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(12)
      );
    } catch (e) {
      // Handle errors here, e.g., show error message to the user
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ignore: unused_element
  void _goToSignUpScreen() {
    Get.to(() => const KayitOlScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF83d1d7),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: const Text('Giriş Yap'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Giriş yap',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0), // Add some space
            const Text(
              'Biz de seni bekliyorduk!',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                fillColor: Colors.white, // Set the background color to white
                filled: true, // Enable filling
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                fillColor: Colors.white, // Set the background color to white
                filled: true, // Enable filling
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator()
                : Container(
              height: 50.0, // Set the height of the button
              width: double.infinity, // Set the width of the button
              decoration: BoxDecoration(
                color: const Color(
                    0xFF6868af), // Set the color of the button
                borderRadius: BorderRadius.circular(
                    30.0), // Make the button circular
              ),
              child: TextButton(
                onPressed: _submitForm,
                child: const Text(
                  'Giriş yap',
                  style: TextStyle(
                    color: Colors.white, // Set the color of the text
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.to(() =>
                const KayitOlScreen()); // Navigate to the GirisScreen when the button is pressed
              },
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black),
                  text: 'Bir hesabın yok mu? ',
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Kayıt ol',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}