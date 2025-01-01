import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginRepo {
  static String _verificationId = '';

  // Method to send OTP
  static Future<void> sendOTP(
      String completePhoneNumber, BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: completePhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically signs in the user if the OTP is sent and verified automatically
        await auth.signInWithCredential(credential);
        print("OTP automatically verified and user signed in!");
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to home
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        print("OTP sent. Verification ID: $verificationId");
        // Optionally, you can navigate to the OTP verification page here
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        print("Code auto-retrieval timeout. Verification ID: $verificationId");
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Method to verify OTP
  static Future<bool> verifyOTP(String otp) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await auth.signInWithCredential(credential);
      print("User signed in successfully!");
      return true; // Verification successful
    } catch (e) {
      print("Error verifying OTP: $e");
      return false; // Verification failed
    }
  }
}
