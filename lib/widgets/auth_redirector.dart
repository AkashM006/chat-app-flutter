import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/on_board.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRedirector extends StatefulWidget {
  const AuthRedirector({super.key, this.user});
  final User? user;

  @override
  State<AuthRedirector> createState() {
    return _AuthRedirectorState();
  }
}

class _AuthRedirectorState extends State<AuthRedirector> {
  late Future<bool> _isNew;

  Future<bool> _isNewUser(User? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isNew = prefs.getBool('isNew');
    return isNew!;
  }

  @override
  void initState() {
    _isNew = _isNewUser(widget.user);
    super.initState();
  }

  Future<void> _skipOnBoarding(
      User? user, String? imageUrl, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNew', false);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'username': name,
        'email': user.email,
        'image_url': imageUrl ?? '',
      });
      setState(() {
        _isNew = Future(() => false);
      });
    } catch (err) {
      print("Not able to upload data to firebase firestore");
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Something went wrong when trying to update your profile. Please try again later'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _isNew,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(
            screenName: 'Auth Redirector',
          );
        }

        if (snapshot.data == false) {
          return const ChatScreen();
        }

        return OnBoardingScreen(
          user: widget.user,
          onFinishOnBoarding: _skipOnBoarding,
        );
      },
    );
  }
}
