import 'package:flutter/material.dart';
import 'package:shotbycamera/src/utils/app_constants.dart' as appConsts;

class TextPositionSelectorWidget extends StatelessWidget {
  final appConsts.TextPosition
      selectedTextPosition; // Add this to know which text position is selected
  final void Function(appConsts.TextPosition) onTextPositionSelect;

  const TextPositionSelectorWidget({
    required this.selectedTextPosition, // Include selectedTextPosition in the constructor
    required this.onTextPositionSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a list of text positions for simplicity
    final textPositions = [
      appConsts.TextPosition.bottomLeft,
      appConsts.TextPosition.bottomCenter,
      appConsts.TextPosition.bottomRight,
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Text Position',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: textPositions.map((position) {
            // Determine if this position is the selected one
            bool isSelected = position == selectedTextPosition;
            return //
                ElevatedButton(
              onPressed: () => onTextPositionSelect(position),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.0,
                ), // Reduced horizontal padding
                backgroundColor: isSelected
                    ? appConsts.AppConstants.selectedButtonColor
                    : Colors.black.withOpacity(0.8),
                foregroundColor: Colors.white,
              ),
              child: Text(
                position == appConsts.TextPosition.bottomLeft
                    ? 'Bottom Left'
                    : position == appConsts.TextPosition.bottomCenter
                        ? 'Bottom Center'
                        : 'Bottom Right',
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
