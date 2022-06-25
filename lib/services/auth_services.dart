import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/users.dart';
import 'db_services.dart';

Future<void> logIn(
  TextEditingController email,
  TextEditingController password,
  BuildContext context,
) async {
  DbServices db = DbServices();

  await FirebaseAuth.instance.signInWithEmailAndPassword(
      //login
      email: email.text.trim(),
      password: password.text);
  await db.userStatusOnline(); // change user status to online
}

Future<void> signUp(
  TextEditingController email,
  TextEditingController password,
  TextEditingController name,
  BuildContext context,
) async {
  DbServices db = DbServices();
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //signup
      email: email.text.trim(),
      password: password.text);

  sendEmailVerification(); // send verification email

  db.addUser(
    Users(
        name: name.text.trim(),
        email: email.text.trim(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        image: ""),
  );
}

Future<void> sendEmailVerification() async {
  await FirebaseAuth.instance.currentUser!.sendEmailVerification();
}

Future<void> passwordReset(BuildContext context) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(
    email: FirebaseAuth.instance.currentUser!.email!,
  );
}

Future<void> forgotPassword(
  TextEditingController email,
  BuildContext context,
) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(
    email: email.text.trim(),
  );
}

Future<void> signOut(BuildContext context) async {
  DbServices db = DbServices();
  await db.userStatusOffline();
  await db.deleteTokenFromDatabase();
  FirebaseAuth auth = FirebaseAuth.instance;
  await auth.signOut();
}

String checkVerifyEmail() {
  if (FirebaseAuth.instance.currentUser != null) {
    if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
      return "VERIFIED";
    }
    return "NOT VERIFIED";
  } else {
    return "NOT VERIFIED";
  }
}
