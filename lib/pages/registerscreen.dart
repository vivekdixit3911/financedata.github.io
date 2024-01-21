// ignore_for_file: camel_case_types, avoid_print, unnecessary_null_comparison, non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/decorations/welocmescreenbuttons.dart';
import 'package:finance/refreal/startrefreal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class registerpage extends StatefulWidget {
  static String id = 'registerpage';
  const registerpage({Key? key});

  @override
  State<registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<registerpage> {
  String? name;
  String? email;
  String? password;

  bool isNameValid = true;
  bool isEmailValid = true;
  bool isPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 191, 216, 243),
            body: ListView(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Hero(
                      tag: "logo",
                      child: const CircleAvatar(
                        backgroundImage: AssetImage("asset/logo.jpg"),
                        radius: 120,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Nice to meet you!",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Welcome back You've ",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      "been missed! ",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 35, right: 50, left: 50),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                            isNameValid = true; // Reset validation
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Name',
                          errorText: isNameValid || name != null
                              ? null
                              : 'Invalid name',
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 35, right: 50, left: 50),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            email = value;
                            isEmailValid = true; // Reset validation
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: isEmailValid || email != null
                              ? null
                              : 'Invalid email',
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 50, left: 50, top: 20),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            password = value;
                            isPasswordValid = true; // Reset validation
                          });
                        },
                        keyboardType: TextInputType.phone,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: isPasswordValid || password != null
                              ? null
                              : 'Invalid password',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    lastredbutton_register_login(
                      onpressed: () async {
                        if (_validateForm()) {
                          final progress = ProgressHUD.of(context);
                          progress?.showWithText("Hold on...");

                          try {
                            await registerUser(name!, email!, password!);
                            Navigator.pushNamed(context, ReferralPageStart.id);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'email-already-in-use') {
                              // Email is already in use, show a specific error message
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Error'),
                                    content: Text(
                                        'Email is already in use. Please use a different email.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Clear the form fields
                                          setState(() {
                                            name = null;
                                            email = null;
                                            password = null;
                                          });
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Handle other FirebaseAuthExceptions
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Error'),
                                    content: Text(
                                        'An error occurred. Please try again.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } on Exception catch (e) {
                            print(e);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'An error occurred. Please try again.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } finally {
                            progress?.dismiss();
                            setState(() {
                              name = null;
                              email = null;
                              password = null;
                            });
                          }
                        } else {
                          // Form is not valid, display a warning
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please fill in all the fields correctly.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      text: "Register",
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _validateForm() {
    bool isValid = true;

    if (name == null || name!.isEmpty) {
      setState(() {
        isNameValid = false;
      });
      isValid = false;
    }

    if (email == null || !RegExp(r'\S+@\S+\.\S+').hasMatch(email!)) {
      setState(() {
        isEmailValid = false;
      });
      isValid = false;
    }

    if (password == null || password!.length < 6) {
      setState(() {
        isPasswordValid = false;
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> registerUser(String name, String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      var generatedide = generateReferralId();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'totalBalance': 0,
        'todaysEarning': 0,
        'numberOfShares': [],
        'referralId': generatedide,
        'transactionsDetails': [],
      });
    } catch (e) {
      print('Error registering user and updating Firestore document: $e');
      rethrow;
    }
  }

  String generateReferralId() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    String referralId = '';
    for (int i = 0; i < 6; i++) {
      referralId += chars[random.nextInt(chars.length)];
    }

    return referralId;
  }
}
