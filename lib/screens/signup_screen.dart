// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/is_loading_provider.dart';
import '../services/auth_services.dart';
import '../widgets/error_dialog.dart';
import '../widgets/text_box.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 10, 50),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 150,
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: CustomTextField(
                      labelText: 'NAME',
                      textController: _nameController,
                      icon: Icons.account_circle_outlined,
                      validatorIsEmpty: 'Please Enter Your Name',
                      validatorError: '',
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: CustomTextField(
                      labelText: 'EMAIL',
                      isEMail: true,
                      textController: _emailController,
                      icon: Icons.email_outlined,
                      validatorError: 'Please enter a valid email address!',
                      validatorIsEmpty: 'Enter Email Address',
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: CustomTextField(
                    textController: _passwordController,
                    labelText: 'PASSWORD',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validatorIsEmpty: '',
                    validatorError: '',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(25, 15, 25, 0),
                  child: Provider.of<IsLoading>(context).isLoading == true
                      ? CircularProgressIndicator()
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  style: ButtonStyle(),
                                  child: Text(
                                    'CREATE ACCOUNT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      Provider.of<IsLoading>(context,
                                              listen: false)
                                          .changeToTrue();
                                      signUp(
                                              _emailController,
                                              _passwordController,
                                              _nameController,
                                              context)
                                          .catchError((err) async {
                                        await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ErrorDialog(
                                                  err: err.message);
                                            });
                                      });
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('EMAIL VERIFICATION'),
                                              content: Text(
                                                  'An Email has been sent with the link to verify your email address'),
                                              actions: [
                                                TextButton(
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0,
                                                          color: Colors.white),
                                                    ),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.blue),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      FirebaseAuth auth =
                                                          FirebaseAuth.instance;
                                                      await auth.signOut();
                                                      Provider.of<IsLoading>(
                                                              context,
                                                              listen: false)
                                                          .changeToFalse();
                                                    })
                                              ],
                                            );
                                          });
                                      Navigator.pop(context);
                                    }
                                  }),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GestureDetector(
                    child: const Text(
                      'Already have an account? Go back',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
}
