import 'package:flutter/material.dart';
import 'package:photo_stamp/src/utils/app_constants.dart';

import 'package:photo_stamp/src/widgets/color_picker.dart';
import 'package:provider/provider.dart';

import '../providers/photo_provider.dart';
import '../providers/stamp_text_provider.dart';
import 'font_size_selector.dart';

class StampTextConfig extends StatelessWidget {
  ///
  final void Function(Color) onColorSelect;
  final void Function(int) onFontSizeChange;
  final void Function(TextPosition?) onPositionSelect;

  ///
  StampTextConfig({
    required this.onColorSelect,
    required this.onFontSizeChange,
    required this.onPositionSelect,
    super.key,
  });

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final stampProvider = Provider.of<StampTextProvider>(context);
    final photoProvider = Provider.of<PhotoProvider>(context);

    ///
    return //
        Column(
      children: [
        Expanded(
          child: FontSizeSelector(
            onFontSizeSelected: (selectedFontSize) {
              stampProvider.setFontSize(selectedFontSize);
              photoProvider.updateFromStampTextProvider(stampProvider);
              print("Selected font size: $selectedFontSize");
            },
          ),
        ),
        ListTile(
          title: Text("Font Color"),
          trailing: GestureDetector(
            onTap: () {
              _showColorPicker(context);
              photoProvider.updateFromStampTextProvider(stampProvider);
            },
            child: CircleAvatar(backgroundColor: stampProvider.fontColor),
          ),
        ),

        // Text Position Selector
        ListTile(
          title: Text('Text Position'),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: stampProvider.textPosition,
              onChanged: (TextPosition? newValue) {
                if (newValue != null) {
                  // Update the provider or state here
                  stampProvider.setTextPosition(newValue);
                  photoProvider.updateFromStampTextProvider(stampProvider);
                }
              },
              items: TextPosition.values.map((TextPosition position) {
                return DropdownMenuItem<TextPosition>(
                  value: position,
                  child: Text(stampProvider.formatTextPosition(position)),
                );
              }).toList(),
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // 'dialogContext' is the context for the dialog
        return AlertDialog(
          title: const Text("Pick a color"),
          content: SingleChildScrollView(
            child: ColorPicker(onColorSelect: (Color color) {
              onColorSelect(color);
              Navigator.of(dialogContext)
                  .pop(); // Close the dialog using 'dialogContext'
            }),
          ),
        );
      },
    );
  }
}
