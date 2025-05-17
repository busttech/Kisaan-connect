import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'locationseltech.dart';
import 'Homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool? buttonclicked = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() {
      buttonclicked = true;
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          buttonclicked = false;
        });
        return; // user canceled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final snapshot = await userRef.get();

        final data = snapshot.data();
        if (snapshot.exists &&
            data != null &&
            data['state'] != null &&
            data['district'] != null &&
            data['village'] != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Homescreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LocationScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        buttonclicked = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/lo.png', height: 120),
              const SizedBox(height: 40),
              Text(
                'Welcome to Kisaan Connect', // Translated welcome message
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              buttonclicked == false
                  ? ElevatedButton.icon(
                    icon: Image.asset('assets/images/images.png', height: 24),
                    label: Text(
                      "Sign in with Google",
                    ), // Translated button text
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => signInWithGoogle(context),
                  )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
