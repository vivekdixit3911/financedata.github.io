import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferralPage extends StatefulWidget {
  static String id = "ReferralPage";

  @override
  _ReferralPageState createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  TextEditingController _referralIdController = TextEditingController();
  String _referralName = '';
  String _currentUserReferralId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserReferralId();
  }

  void _fetchCurrentUserReferralId() {
    String userId = getCurrentUserId();

    if (userId.isNotEmpty) {
      FirebaseFirestore.instance.collection('users').doc(userId).get().then(
        (DocumentSnapshot<Map<String, dynamic>> snapshot) {
          setState(() {
            _currentUserReferralId = snapshot['referralId'] ?? '';
          });
        },
      ).catchError((error) {
        print('Error fetching current user referralId: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referral Page'),
      ),
      body: Container(
        color: Colors.lightBlueAccent,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Referral ID:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _currentUserReferralId,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _copyToClipboard(_currentUserReferralId);
              },
              child: Text('Copy to Clipboard'),
            ),
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchReferralDetails();
              },
              child: Text('Fetch Referral Details'),
            ),
            SizedBox(height: 16),
            if (_referralName.isNotEmpty) _buildReferralDetailsSection(),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _referralIdController,
      decoration: InputDecoration(
        labelText: 'Enter Referral ID',
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildReferralDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Future<void> _fetchReferralDetails() async {
    setState(() {
      _isLoading = true;
      _referralName = ''; // Reset referralName while loading
    });

    String inputReferralId = _referralIdController.text.trim();

    if (inputReferralId.isEmpty) {
      _showWarning('Please enter a Referral ID.');
      setState(() {
        _isLoading = false;
      });
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
          _referralName = referralData!['name'] ?? '';
        });
        _showReferralPopup();
      } else {
        _showWarning('Referral ID not found.');
      }
    } catch (e) {
      print('Error fetching referral data: $e');
      _showWarning('Error fetching referral data. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

        Map<String, dynamic> userData = userDoc.data() ?? {};
        List<dynamic> referees = userData['referees'] ?? [];

        if (!referees.any((referee) =>
            referee['referralId'] == _referralIdController.text &&
            referee['referralName'] == _referralName)) {
          referees.add({
            'referralId': _referralIdController.text,
            'referralName': _referralName,
          });

          await userDocRef.set({'referees': referees}, SetOptions(merge: true));

          _showSuccessMessage();
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

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral ID copied to clipboard'),
      ),
    );
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
}
