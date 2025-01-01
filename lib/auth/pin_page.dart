import 'package:flutter/material.dart';
import '/app_theme/custom_theme.dart';
import 'login_service.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                color: Color(0xFFBCB3EF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Image.network(
                  "https://raw.githubusercontent.com/kkbughunter/Final-Year-Project/refs/heads/Auth/project-assets/images/login_img.png",
                  width: 450,
                  height: 300,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter Your PIN",
                      style: CustomTheme.h1(),
                    ),
                  ),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Your PIN',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Verify OTP
                      LoginService.verifyOTP(
                        _pinController.text,
                        context,
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
