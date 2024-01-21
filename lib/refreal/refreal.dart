import 'package:finance/companydetail/details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class ReferralPage extends StatefulWidget {
//   const ReferralPage({Key? key}) : super(key: key);

//   @override
//   State<ReferralPage> createState() => _ReferralPageState();
// }

// class _ReferralPageState extends State<ReferralPage> {
//   late User? _currentUser; // Firebase user
//   String? _currentUserReferralId; // Referral ID fetched from user details
//   Map<String, dynamic>? userData;
//   String searchErrorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//   }

//   void _getCurrentUser() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         _currentUser = user;
//       });

//       getUserDetailsByReferralId(_currentUser!.uid);
//     }
//   }

//   void copyReferralIdToClipboard() {
//     if (_currentUserReferralId != null) {
//       FlutterClipboard.copy(_currentUserReferralId!).then((_) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Referral ID copied to clipboard'),
//         ));
//       });
//     }
//   }

//   void getUserDetailsByReferralId(String userId) {
//     setState(() {
//       userData = null;
//       searchErrorMessage = '';
//     });

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .get()
//         .then((DocumentSnapshot documentSnapshot) {
//       if (documentSnapshot.exists) {
//         setState(() {
//           userData = documentSnapshot.data() as Map<String, dynamic>;
//           // Fetch referralId from user details and display it
//           String referralId = userData!['referralId'] ?? 'Not available';
//           // Update the UI with the fetched referralId
//           _updateReferralId(referralId);
//         });
//       } else {
//         setState(() {
//           searchErrorMessage = 'No user found with this referral ID';
//         });
//       }
//     }).catchError((error) {
//       print('Error searching for user details: $error');
//       setState(() {
//         searchErrorMessage = 'Error searching for user details';
//       });
//     });
//   }

//   void _updateReferralId(String referralId) {
//     // Update the UI with the fetched referralId
//     setState(() {
//       _currentUserReferralId = referralId;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Text('Your Referral ID:', style: TextStyle(fontSize: 18.0)),
//           SizedBox(height: 8.0),
//           Text(
//             _currentUserReferralId ?? 'Not logged in',
//             style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 16.0),
//           ElevatedButton(
//             onPressed: copyReferralIdToClipboard,
//             child: Text('Copy to Clipboard'),
//           ),
//           SizedBox(height: 16.0),
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: 'Enter Referral ID',
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) {
//               // You can choose whether to update referralId based on user input or not
//               // For now, let's leave it as it is
//             },
//           ),
//           SizedBox(height: 8.0),
//           ElevatedButton(
//             onPressed: () {
//               getUserDetailsByReferralId(_currentUser?.uid ?? '');
//             },
//             child: Text('Get User Details'),
//           ),
//           if (searchErrorMessage.isNotEmpty) ...[
//             SizedBox(height: 16.0),
//             Text(
//               searchErrorMessage,
//               style: TextStyle(color: Colors.red),
//             ),
//           ],
//           if (userData != null) ...[
//             SizedBox(height: 16.0),
//             Text('Referred by: ${userData!['name']}'),
//             // Display other user details as needed
//           ],
//         ],
//       ),
//     );
//   }
// }

// 0000000000000000000000000000000000//
class ReferralPage extends StatefulWidget {
  static String id = "FetchReferralIdsPage";

  @override
  ReferralPageState createState() => ReferralPageState();
}

class ReferralPageState extends State<ReferralPage> {
  TextEditingController _referralIdController = TextEditingController();
  String _referralName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    try {
      String userId = "YourUserDocumentId"; 

      // Access the collection for the user's referred people details
      CollectionReference refredPeopleDetailsCollection = FirebaseFirestore
          .instance
          .collection('users')
          .doc(userId)
          .collection('refred_people_detail');

      // Check if the referral ID is already in the collection
      QuerySnapshot querySnapshot = await refredPeopleDetailsCollection
          .where('referralId', isEqualTo: _referralIdController.text)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Add the new referral details as a document in the collection
        await refredPeopleDetailsCollection.add({
          'referralId': _referralIdController.text,
          'referralName': _referralName,
        });

        print('Referral details saved successfully in the collection.');
      } else {
        _showWarning(
            'Referral ID already exists in your refred_people_detail collection.');
      }
    } catch (e) {
      print('Error saving referral details: $e');
      _showWarning('Error saving referral details. Please try again.');
    }
  }
}
