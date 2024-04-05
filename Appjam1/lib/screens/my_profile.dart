// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final XFile? selected =
    await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = selected;
    });

    if (_imageFile != null) {
      final File file = File(_imageFile!.path);
      // ignore: use_build_context_synchronously
      await uploadImageToFirebase(context, file);
    }
  }

  Future<void> uploadImageToFirebase(BuildContext context, File file) async {
    String fileName = FirebaseAuth.instance.currentUser!.uid;
    FirebaseStorage storage = FirebaseStorage.instance;

    try {
      await storage.ref('uploads/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchSwipedRightPlaces() {
    final databaseReference = FirebaseDatabase(
      databaseURL:
      'https://appjam-1-default-rtdb.europe-west1.firebasedatabase.app',
    ).reference().child('swipedRight');

    return databaseReference.onValue.map((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> places = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        return places.values
            .map((value) => Map<String, dynamic>.from(value))
            .toList();
      } else {
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profilim'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 12,
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(File(_imageFile!.path)) as ImageProvider<Object>?
                  : (FirebaseAuth.instance.currentUser!.photoURL != null &&
                  FirebaseAuth
                      .instance.currentUser!.photoURL!.isNotEmpty)
                  ? NetworkImage(
                  FirebaseAuth.instance.currentUser!.photoURL!)
                  : const AssetImage('assets/user.png')
              as ImageProvider<Object>,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(FirebaseAuth.instance.currentUser!.displayName ?? ''),
            const SizedBox(
              height: 12,
            ),
            Text(FirebaseAuth.instance.currentUser!.email ?? ''),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Profil resmini değiştir'),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Gitmek istediğim yerler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchSwipedRightPlaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Text("There's nothing here");
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> place = snapshot.data![index];
                        if (place['imageUrl'] == null &&
                            place['name'] == null &&
                            place['address'] == null) {
                          return Container();
                        } else {
                          return ListTile(
                            leading: (place['imageUrl'] != null)
                                ? Image.network(place['imageUrl'])
                                : const Icon(Icons.image),
                            title: Text(place['name'] ?? ''),
                            subtitle:
                            Text(place['address'] ?? 'Önce sağa kaydırın'),
                          );
                        }
                      },
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}