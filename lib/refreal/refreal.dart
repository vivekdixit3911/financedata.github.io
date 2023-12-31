import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clipboard/clipboard.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({Key? key}) : super(key: key);

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String referralId = '123456'; // Fixed unique ID
  Map<String, dynamic>? userData;
  String searchErrorMessage = '';

  @override
  void initState() {
    super.initState();
    getUserDetailsByReferralId(
        referralId); // Retrieve user details on initialization
  }

  void copyReferralIdToClipboard() {
    FlutterClipboard.copy(referralId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Referral ID copied to clipboard'),
      ));
    });
  }

  void getUserDetailsByReferralId(String inputReferralId) {
    // Reset previous state
    setState(() {
      userData = null;
      searchErrorMessage = '';
    });

    // Search for the user with the given referral ID
    FirebaseFirestore.instance
        .collection('users')
        .where('referralId', isEqualTo: inputReferralId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // User with the provided referral ID found
        setState(() {
          userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        });
      } else {
        // User with the provided referral ID not found
        setState(() {
          searchErrorMessage = 'No user found with this referral ID';
        });
      }
    }).catchError((error) {
      print('Error searching for user details: $error');
      setState(() {
        searchErrorMessage = 'Error searching for user details';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Your Referral ID:', style: TextStyle(fontSize: 18.0)),
          SizedBox(height: 8.0),
          Text(referralId,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: copyReferralIdToClipboard,
            child: Text('Copy to Clipboard'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Enter Referral ID',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // You can choose whether to update referralId based on user input or not
              // For now, let's leave it as it is
            },
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              getUserDetailsByReferralId(referralId);
            },
            child: Text('Get User Details'),
          ),
          if (searchErrorMessage.isNotEmpty) ...[
            SizedBox(height: 16.0),
            Text(
              searchErrorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
          if (userData != null) ...[
            SizedBox(height: 16.0),
            Text('Referred by: ${userData!['name']}'),
            // Display other user details as needed
          ],
        ],
      ),
    );
  }
}
