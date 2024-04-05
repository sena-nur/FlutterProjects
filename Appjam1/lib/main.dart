import 'package:appjam_1/screens/giris_yap.dart';
import 'package:appjam_1/screens/maps.dart';
import 'package:appjam_1/screens/my_profile.dart';
import 'package:appjam_1/screens/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase/firebase_options.dart';
import 'screens/main_menu.dart';
// Import Get library

Future<void> main() async {
  // Initialize Firebase
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Use GetMaterialApp instead of MaterialApp
      title: 'Lokal Gezgin',

      getPages: [
        GetPage(name: '/login', page: () => const GirisScreen()),
        GetPage(name: '/mainMenu', page: () => const MainMenu()),
        GetPage(name: '/maps', page: () => const MapScreen()),
        GetPage(name: '/myprofile', page: () => const MyProfile()),
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User? user = snapshot.data;
            if (user == null) {
              return const WelcomeScreen(); // No need for const here
            } else {
              return const MainMenu(); // No need for const here
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}