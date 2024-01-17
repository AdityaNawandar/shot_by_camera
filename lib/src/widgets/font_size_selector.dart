import 'package:flutter/material.dart';

class FontSizeSelector extends StatelessWidget {
  final String sampleText = "Sample Text";
  final List<int> fontSizes = [12, 16, 20, 24, 28, 32, 48, 60, 80, 100, 120];
  final void Function(int) onFontSizeSelected;

  FontSizeSelector({required this.onFontSizeSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fontSizes.length,
      itemBuilder: (context, index) {
        int fontSize = fontSizes[index];
        return ListTile(
          title: Text(
            sampleText,
            style: TextStyle(fontSize: fontSize.toDouble()),
          ),
          onTap: () => onFontSizeSelected(fontSize),
        );
      },
    );
  }
}
