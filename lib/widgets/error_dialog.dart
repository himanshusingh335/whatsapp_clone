// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/is_loading_provider.dart';
import '../screens/landing_screen.dart';

class ErrorDialog extends StatelessWidget {
  final String err;
  const ErrorDialog({Key? key, required this.err}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("ERROR"),
      content: Text(err),
      actions: [
        TextButton(
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (Route<dynamic> route) => false);
            Provider.of<IsLoading>(context, listen: false).changeToFalse();
          },
        )
      ],
    );
  }
}
