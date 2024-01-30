import 'package:finance/bottombarinitalpage/bottombarpage.dart';
import 'package:finance/decorations/inputfields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../decorations/welocmescreenbuttons.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

class loginscreen extends StatefulWidget {
  static String id = "loginscreen";
  const loginscreen({Key? key}) : super(key: key);

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  late String username = "";
  late String userpassword = "";

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 216, 243),
      body: ProgressHUD(
        child: Builder(builder: (context) {
          return ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  Hero(
                    tag: "logo",
                    child: CircleAvatar(
                      backgroundImage: AssetImage("asset/logo.jpg"),
                      radius: 150,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Nice to meet you!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
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
                        const EdgeInsets.only(right: 50, left: 50, top: 30),
                    child: TextFormField(
                      onChanged: (value) {
                        username = value;
                      },
                      decoration: inputdecorpassword,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 50, left: 50, top: 20),
                    child: TextFormField(
                      onChanged: (value) {
                        userpassword = value;
                      },
                      keyboardType: TextInputType.phone,
                      obscureText: true,
                      decoration: inputdecorpassword,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 200),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forget Password",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: lastredbutton_register_login(
                      onpressed: () async {
                        final progress = ProgressHUD.of(context);
                        progress?.showWithText("Ruko JARA..");

                        if (username == null ||
                            username.isEmpty ||
                            userpassword == null ||
                            userpassword.isEmpty) {
                          _showSnackBar(context,
                              'Please enter both username and password.');
                          progress?.dismiss();
                          return;
                        }

                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: username, password: userpassword);

                          Navigator.pushNamed(context, bottombar.id);
                          progress?.dismiss();
                        } catch (e) {
                          print(e);
                          _showSnackBar(context,
                              'Invalid credentials. Please try again.');
                          progress?.dismiss();
                        }
                      },
                      text: "Login",
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
