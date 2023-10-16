import 'package:chat_app/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggedInScreen extends StatelessWidget {
  final User? user;

  const LoggedInScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return const ChatScreen();
  }
}
