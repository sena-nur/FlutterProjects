import 'package:appjam_1/screens/giris_yap.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Import Get library

class KayitOlScreen extends StatefulWidget {
  const KayitOlScreen({Key? key}) : super(key: key);

  @override
  KayitOlScreenState createState() => KayitOlScreenState();
}

class KayitOlScreenState extends State<KayitOlScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Update the user's profile with the name and surname
      await userCredential.user!
          .updateDisplayName("${_nameController.text.trim()} ");

      // Show a snackbar
      Get.snackbar(
          'Kayıt Başarılı', // title
          'Giriş ekranına yönlendiriliyorsun', // message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(12)
      );

      // Delay navigation to show the snackbar
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to the sign-up page
      Get.offAll(() => const GirisScreen()); // Use Get to navigate
    } catch (e) {
      // Handle errors here, e.g., show error message to the user
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfbeee0),
      // appBar: AppBar(
      //   title: const Text('Kayıt Ol'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Kayıt ol',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0), // Add some space
            const Text(
              'Lokal gezgin ailesine katılmana çok az kaldı!',
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
              controller: _nameController,
              decoration: InputDecoration(
                fillColor: Colors.white, // Set the background color to white
                filled: true, // Enable filling
                labelText: 'Kullanıcı Adı',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
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
                    0xFF83d1d8), // Set the color of the button
                borderRadius: BorderRadius.circular(
                    30.0), // Make the button circular
              ),
              child: TextButton(
                onPressed: _submitForm,
                child: const Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    color: Colors.black, // Set the color of the text
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: () {
                Get.to(() =>
                const GirisScreen()); // Navigate to the GirisScreen when the button is pressed
              },
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black),
                  text: 'Bir hesabın var mı? ',
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Giriş yap',
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