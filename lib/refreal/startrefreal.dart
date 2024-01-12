import 'package:finance/companydetail/details.dart';
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
                MaterialPageRoute(builder: (context) => UserDataDisplay()),
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
                // Access the bottombar state using the global key
                var bottombarKey;
                bottombarKey.currentState?.navigateToUserDataDisplay();

                // Close the dialog
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
    String userId = "YourUserDocumentId"; // Replace with the actual user ID.

    try {
      // Fetch the existing user data
      DocumentReference<Map<String, dynamic>> userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot<Map<String, dynamic>> userDoc = await userDocRef.get();

      // Extract the existing referees list or initialize an empty list
      List<dynamic> referees = userDoc.get('referees') ?? [];

      // Check if the referral ID is already in the list
      if (!referees.contains(_referralIdController.text)) {
        // Add the new referral ID to the list
        referees.add({
          'referralId': _referralIdController.text,
          'referralName': _referralName,
        });

        // Update the user document with the new referees list
        await userDocRef.set({'referees': referees}, SetOptions(merge: true));

        // Optionally, you can show a success message or update the UI
        print('Referral details saved successfully.');
      } else {
        _showWarning('Referral ID already exists in your referees list.');
      }
    } catch (e) {
      print('Error saving referral details: $e');
      _showWarning('Error saving referral details. Please try again.');
    }
  }
}
