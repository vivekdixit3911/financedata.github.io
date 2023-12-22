import 'package:firebase_auth/firebase_auth.dart';

Future<void> register(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  } catch (e) {
    print("registration not confirmed do it again");
  }
}

Future<void> registerphone(String phoneNumber) async {
  try {
    // Start the phone number verification process.
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Sign in the user with the PhoneAuthCredential.
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle the error.
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Show the user the verification code.
        print('The verification code is: $verificationId');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // The user did not automatically retrieve the verification code.
        print('The user did not automatically retrieve the verification code.');
      },
    );
  } on FirebaseAuthException catch (e) {
    // Handle the error.
    print(e.message);
  }
}
