import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class FontSizeSelectorWidget extends StatelessWidget {
  final int selectedFontSize; // Add this to know which font size is selected
  final void Function(int) onFontSizeSelected;

  const FontSizeSelectorWidget({
    required this.selectedFontSize,
    required this.onFontSizeSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Font Size',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Wrap(
            spacing: 15,
            children: AppConstants.fontSizes.map((size) {
              bool isSelected = size == selectedFontSize;

              // Use the map to get the label for the current size
              String label =
                  AppConstants.fontSizeLabels[size] ?? size.toString();

              return ElevatedButton(
                onPressed: () => onFontSizeSelected(size),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppConstants.selectedButtonColor
                      : Colors.black.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize:
                          size.toDouble()), // Use the actual size for the text
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
