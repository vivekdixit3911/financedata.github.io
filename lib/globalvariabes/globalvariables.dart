import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Register a new user
Future<dynamic> registerUser(String email, String password, String name,
    String phoneNumber, String address) async {
  // Use Firebase Authentication to register the user
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // After successful registration, use Firestore to store additional user data
  User? user = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
    'name': name,
    'phone_number': phoneNumber,
    'address': address,
    // Add other fields as needed
  });
}

// Sign in existing user
Future<void> signInUser(String email, String password) async {
  // Use Firebase Authentication to sign in the user
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

// Fetch user data from Firestore
Future<Map<String, dynamic>?> fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

  if (userSnapshot.exists) {
    return userSnapshot.data() as Map<String, dynamic>;
  } else {
    return null;
  }
}
