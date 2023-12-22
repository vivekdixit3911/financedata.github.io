import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class refreal extends StatefulWidget {
  const refreal({super.key});

  @override
  State<refreal> createState() => _SharePageState();
}

class _SharePageState extends State<refreal> {
  String referralId = '';
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    final uuid = Uuid();
    referralId = uuid.v4();
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
            onPressed: () {},
            child: Text('Copy to Clipboard'),
          ),
          if (userData != null) ...[
            Text('Referred by: ${userData!['name']}'),
          ],
        ],
      ),
    );
  }
}
