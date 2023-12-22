import 'package:finance/allshares/allshares.dart';
import 'package:finance/pages/welcomescreen.dart';
import 'package:finance/refreal/refreal.dart';
import 'package:finance/userdetail/userdetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';

import '../companydetail/details.dart';

class bottombar extends StatefulWidget {
  static String id = "bottombar";
  const bottombar({super.key});

  @override
  State<bottombar> createState() => _bottombarState();
}

class _bottombarState extends State<bottombar> {
  final _controller = PageController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 194, 255, 248),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(Icons.wifi_channel_rounded, color: Colors.white),
                  backgroundColor: Color.fromARGB(255, 63, 223, 223),
                ),
                Text(
                  " Groww",
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                try {
                  _auth.signOut();
                  Navigator.pushNamed(context, welcomeScreen.id);
                } catch (e) {}
              },
              icon: CircleAvatar(child: Icon(Icons.person)),
              color: Colors.white,
            )
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 95, 210, 174),
      body: PageView(
        controller: _controller,
        children: <Widget>[
          UserDataDisplay(),
          sahres(),
          refreal(),
          user_details(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: RollingBottomBar(
        controller: _controller,
        flat: true,
        useActiveColorByDefault: false,
        items: [
          RollingBottomBarItem(FontAwesomeIcons.building,
              label: 'Home', activeColor: Colors.redAccent),
          RollingBottomBarItem(FontAwesomeIcons.moneyBill1,
              label: 'Buy', activeColor: Colors.blueAccent),
          RollingBottomBarItem(FontAwesomeIcons.solidShareFromSquare,
              label: 'Share', activeColor: Color.fromARGB(255, 4, 255, 88)),
          RollingBottomBarItem(FontAwesomeIcons.vault,
              label: 'Details', activeColor: Colors.orangeAccent),
        ],
        enableIconRotation: true,
        onTap: (index) {
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
