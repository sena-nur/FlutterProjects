import 'package:appjam_1/screens/swipe_page.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'my_profile.dart'; // Import Get library
import "maps.dart";

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  int _currentIndex = 0; //default index of a first screen
  final _pageController = PageController();

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the login screen
      Get.offAllNamed('/login');
    } catch (e) {
      // Handle sign-out errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // Prevents the user from going back
      child: Scaffold(
        drawer: Drawer(

          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.purple,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Text(
                      'Hoşgeldin ${FirebaseAuth.instance.currentUser!.displayName}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    CircleAvatar(
                      radius: 25.0,
                      backgroundImage: FirebaseAuth
                          .instance.currentUser?.photoURL !=
                          null
                          ? NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!)
                          : const AssetImage('assets/user.png') as ImageProvider<
                          Object>, // Add your default profile image path here
                      // backgroundColor: Colors.transparent,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Ayarlar'),
                onTap: () {
                  Get.snackbar('Yakında', "",
                      // title// message
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1),
                      margin: const EdgeInsets.all(12));
                },
              ),
              ListTile(
                title: const Text('Çıkış Yap'),
                onTap: () {
                  _signOut(context);
                  Get.snackbar('Çıkış Yapıldı', "",
                      // title// message
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1),
                      margin: const EdgeInsets.all(12));
                }, // Call _signOut method on tap
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Lokal Gezgin v1.0.0'),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: const <Widget>[
            SwipePage(),
            MapScreen(),
            MyProfile()
            // Add more pages here for more tabs
          ],
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              icon: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              activeColor: Colors.purple,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.map),
              title: const Text('Haritam'),
              activeColor: Colors.purple,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Profilim'),
              activeColor: Colors.purple,
            ),
            // Add more items for more tabs
          ],
        ),
      ),
    );
  }
}