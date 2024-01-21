import 'package:finance/pages/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralPageStart extends StatefulWidget {
  static String id = "FetchReferralIdsPage";

  @override
  _ReferralPageStartState createState() => _ReferralPageStartState();
}

class _ReferralPageStartState extends State<ReferralPageStart> {
  TextEditingController _referralIdController = TextEditingController();
  String _referralName = '';

  final GlobalKey<BottomBarState> bottombarKey = GlobalKey<BottomBarState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Referral IDs and Names'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _referralIdController,
              decoration: InputDecoration(
                labelText: 'Enter Referral ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _fetchReferralDetails();
            },
            child: Text('Fetch Referral Details'),
          ),
          SizedBox(height: 16),
          if (_referralName.isNotEmpty)
            Column(
              children: [
                Text('Referral Details:'),
                Text('Referral ID: ${_referralIdController.text}'),
                Text('Referral Name: $_referralName'),
                ElevatedButton(
                  onPressed: () {
                    _saveReferralDetails();
                  },
                  child: Text('Save Referral Details'),
                ),
                SizedBox(height: 16),
              ],
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => loginscreen()),
              );
            },
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchReferralDetails() async {
    String inputReferralId = _referralIdController.text.trim();

    if (inputReferralId.isEmpty) {
      _showWarning('Please enter a Referral ID.');
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      QueryDocumentSnapshot<Map<String, dynamic>>? referralData;

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        if (doc['referralId'] == inputReferralId) {
          referralData = doc;
          break;
        }
      }

      if (referralData != null) {
        setState(() {
          _referralName = referralData!['name'];
        });
        _showReferralPopup();
      } else {
        _showWarning('Referral ID not found.');
      }
    } catch (e) {
      print('Error fetching referral data: $e');
      _showWarning('Error fetching referral data. Please try again.');
    }
  }

  void _showReferralPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Referral Details'),
          content: Text('Referral Name: $_referralName'),
          actions: [
            ElevatedButton(
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

  void _showWarning(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                bottombarKey.currentState?.navigateToUserDataDisplay();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReferralDetails() async {
    try {
      String userId = getCurrentUserId();

      if (userId.isNotEmpty) {
        DocumentReference<Map<String, dynamic>> userDocRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        DocumentSnapshot<Map<String, dynamic>> userDoc = await userDocRef.get();

        // Ensure the "referees" field exists in the document
        Map<String, dynamic> userData = userDoc.data() ?? {};
        List<dynamic> referees = userData['referees'] ?? [];

        if (!referees.any((referee) =>
            referee['referralId'] == _referralIdController.text &&
            referee['referralName'] == _referralName)) {
          referees.add({
            'referralId': _referralIdController.text,
            'referralName': _referralName,
          });

          // Update the document with the new referees list
          await userDocRef.set({'referees': referees}, SetOptions(merge: true));

          _showSuccessMessage();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => loginscreen()),
          );
        } else {
          _showWarning(
              'Referral details already exist. Please refer to someone else.');
        }
      } else {
        _showWarning('User not authenticated.');
      }
    } catch (e) {
      print('Error saving referral details: $e');
      _showWarning('Error saving referral details. Please try again.');
    }
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Referral details saved successfully.'),
          actions: [
            ElevatedButton(
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
}

String getCurrentUserId() {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      return '';
    }
  } catch (e) {
    print('Error getting current user ID: $e');
    return '';
  }
}

class BottomBar extends StatefulWidget {
  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  void navigateToUserDataDisplay() {
    print('Navigating to UserDataDisplay');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              navigateToUserDataDisplay();
            },
            child: Text('Navigate'),
          ),
        ],
      ),
    );
  }
}

class UserDataDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data Display'),
      ),
      body: Center(
        child: Text('Display user data here.'),
      ),
    );
  }
}
