import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stamp_text_provider.dart';

class TitleTextInputWidget extends StatelessWidget {
  ///
  final String initialText;
  final Function onTextSubmit;

  ///
  const TitleTextInputWidget({
    this.initialText = '',
    required this.onTextSubmit,
    key,
  }) : super(key: key);

  ///
  @override
  Widget build(BuildContext context) {
    final stampProvider = Provider.of<StampTextProvider>(context);
    // // Set the initial text value
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   stampProvider.textController.text = initialText;
    // });

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Title',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: stampProvider.textController,
          maxLength: 30,
          decoration: const InputDecoration(
            hintText: 'Enter your text here',
            fillColor: Colors.white, // Set the inside color to white
            filled: true,
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black), // Black border for all sides
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors
                      .black), // Black border for all sides in default state
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors
                      .black), // Black border for all sides when the field is focused
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10.0,
            ),
            isDense: true, // Keep the field compact
          ),
        ),
      ],
    );
  }
}
