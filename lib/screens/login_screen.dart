import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:whatsapp_clone/screens/signup_screen.dart';

import '../providers/is_loading_provider.dart';
import '../services/auth_services.dart';
import '../widgets/error_dialog.dart';
import '../widgets/text_box.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 10, 50),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 150,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: CustomTextField(
                    textController: _emailController,
                    labelText: 'EMAIL',
                    icon: Icons.email_outlined,
                    isEMail: true,
                    validatorIsEmpty: 'Enter Email Address',
                    validatorError: 'Please enter a valid email address!',
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: CustomTextField(
                      textController: _passwordController,
                      labelText: 'PASSWORD',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validatorIsEmpty: '',
                      validatorError: '',
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 30, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          onTap: () {
                            forgotPassword(_emailController, context)
                                .catchError((err) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ErrorDialog(err: err.message);
                                  });
                            });
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Provider.of<IsLoading>(context).isLoading == true
                      ? const CircularProgressIndicator()
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    Provider.of<IsLoading>(context,
                                            listen: false)
                                        .changeToTrue();
                                    await logIn(
                                      _emailController,
                                      _passwordController,
                                      context,
                                    ).catchError((err) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ErrorDialog(
                                                err: err.message.toString());
                                          });
                                    });
                                    if (checkVerifyEmail() == "NOT VERIFIED") {
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'EMAIL NOT VERFIED'),
                                              content: const Text(
                                                  'Please verify your email address to login'),
                                              actions: [
                                                TextButton(
                                                    child: const Text(
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
                                                    }),
                                                TextButton(
                                                    child: const Text(
                                                      "RESEND MAIL",
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
                                                      Provider.of<IsLoading>(
                                                              context,
                                                              listen: false)
                                                          .changeToFalse();
                                                      await sendEmailVerification();
                                                    })
                                              ],
                                            );
                                          });
                                    }
                                  }
                                },
                                child: const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GestureDetector(
                      child: const Text(
                        "New User? Sign Up using Email",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, SignupScreen.routeName);
                      }),
                ),
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
    _emailController.dispose();
    _passwordController.dispose();
  }
}
