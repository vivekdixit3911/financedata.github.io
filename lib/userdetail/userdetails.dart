// ignore_for_file: depend_on_referenced_packages

import 'package:finance/payment/payment.dart';
import 'package:flutter/material.dart';


int total_balance = 0;
int added_balance = 0;
int share_balance = 0;
int withdrawal = 0;

class user_details extends StatefulWidget {
  static String id = 'user_details';
  const user_details({super.key});

  @override
  State<user_details> createState() => _user_detailsState();
}

class _user_detailsState extends State<user_details> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("$total_balance"),
          Text("$added_balance"),
          Text("$share_balance"),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Text("add balance"),
          )
        ],
      ),
    );
  }
}
