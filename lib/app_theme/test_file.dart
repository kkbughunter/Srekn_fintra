
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _switchValue = true;
  bool _checkboxValue = false;
  double _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Theme Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline and Body Text
            Text(
              'Headline 1 Text',
              style: theme.textTheme.displayLarge,
            ),
            Text(
              'Body Text 1',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Elevated Button
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            const SizedBox(height: 16),

            // Text Button
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
            const SizedBox(height: 16),

            // Outlined Button
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 16),

            // Switch
            Switch(
              value: _switchValue,
              onChanged: (bool value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Checkbox
            Checkbox(
              value: _checkboxValue,
              onChanged: (bool? value) {
                setState(() {
                  _checkboxValue = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Slider
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              onChanged: (double value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Primary Color Box
            Container(
              height: 100,
              width: double.infinity,
              color: theme.primaryColor,
              child: const Center(
                child: Text(
                  'Primary Color Box',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Color Box
            Container(
              height: 100,
              width: double.infinity,
              color: theme.colorScheme.secondary,
              child: const Center(
                child: Text(
                  'Secondary Color Box',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Background Color Box
            Container(
              height: 100,
              width: double.infinity,
              color: theme.colorScheme.surface,
              child: const Center(
                child: Text(
                  'Background Color Box',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Surface Color Box
            Container(
              height: 100,
              width: double.infinity,
              color: theme.colorScheme.surface,
              child: const Center(
                child: Text(
                  'Surface Color Box',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card Widget with Elevation
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Card Widget',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}