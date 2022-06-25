import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_services.dart';
import 'conversations_screen.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);
  static const routeName = '/landingScreen';

  @override
  Widget build(BuildContext context) {
    return Provider.of<User?>(context) == null ||
            checkVerifyEmail() ==
                "NOT VERIFIED" //if user is signed in and his email is verfied, route to Conversations Screen else, route to login screen
        ? const LoginScreen()
        : const ConversationsScreen();
  }
}
