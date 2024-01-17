import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  ///
  String _selectedValue = 'Option 1';

  ///
  @override
  Widget build(BuildContext context) {
    ///
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null) {
                _selectedValue = newValue;
              }
            });
          },
          items: <String>['Option 1', 'Option 2', 'Option 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
