import 'package:flutter/material.dart';
import '/auth/login_repo.dart';

class LoginService {
  static Future<void> sendOTP(
    String countryCode,
    String phoneNumber,
    BuildContext context,
  ) async {
    String completePhoneNumber = countryCode + phoneNumber;
    print("Phone Number: $completePhoneNumber");

    try {
      await LoginRepo.sendOTP(completePhoneNumber, context);
      // Optionally, you can show a snackbar or dialog here to indicate OTP was sent.
    } catch (e) {
      print("Error during sending OTP: $e");
      // Handle the error (e.g., show a message to the user)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  static Future<void> verifyOTP(String otp, BuildContext context) async {
    try {
      // Call the repository method to verify the OTP
      bool success = await LoginRepo.verifyOTP(otp);

      if (success) {
        // OTP verification successful
        // Navigate to the next screen, e.g., the home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // OTP verification failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP, please try again.')),
        );
      }
    } catch (e) {
      print("Error during OTP verification: $e");
      // Handle the error (e.g., show a message to the user)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
    }
  }
}
