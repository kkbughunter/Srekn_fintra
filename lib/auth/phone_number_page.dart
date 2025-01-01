import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import '/app_theme/custom_theme.dart';
import '/auth/pin_page.dart';
import 'login_service.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';

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
                      "Enter Phone Number",
                      style: CustomTheme.h1(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CountryCodePicker(
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value.dialCode!;
                        });
                      },
                      initialSelection: 'IN',
                      favorite: const ['+91', 'IN'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: true,
                    ),
                  ),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, // Prevent dismissing the dialog
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      // Simulate OTP sending and 5 seconds delay
                      LoginService.sendOTP(
                        _selectedCountryCode,
                        _phoneController.text,
                        context,
                      ).then((_) {
                        Future.delayed(const Duration(seconds: 5), () {
                          // Close the loading dialog
                          Navigator.pop(context);

                          // Navigate to PIN page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PinPage()),
                          );
                        });
                      });
                    },
                    child: const Text('Next'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
