import 'package:flutter/material.dart';
import 'package:shotbycamera/src/providers/stamp_text_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/stamp_text_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ///
    final stampProvider =
        Provider.of<StampTextProvider>(context, listen: false);

    ///
    return //
        Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: StampTextConfig(
            onColorSelect: (color) {
              stampProvider.fontColor = color;
            },
            onFontSizeChange: (size) {
              stampProvider.fontSize = size;
            },
            onTextPositionSelect: (position) {
              stampProvider.textPosition = position;
            },
            onTextSubmit: (newText) {
              stampProvider.text = newText;
            },
          ),
        ),
      ),
    );
  }
}
