import 'package:flutter/material.dart';
import 'package:shotbycamera/src/utils/app_constants.dart';

import 'package:shotbycamera/src/widgets/color_picker.dart';
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
        ListTile(
          title: Text("Font Size"),
          trailing: Container(
            width: 48, // Define a suitable width
            height: 48, // Define a suitable height
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showFontSizePicker(context, stampProvider, photoProvider);
              },
            ),
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

  void _showFontSizePicker(
    BuildContext context,
    StampTextProvider stampTextProvider,
    PhotoProvider photoProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Choose Font Size"),
          content: Container(
            width: double.maxFinite, // Width of the AlertDialog
            height: 300, // Set a fixed height for the ListView
            child: FontSizeSelector(
              onFontSizeSelected: (selectedFontSize) {
                stampTextProvider.setFontSize(selectedFontSize);
                photoProvider.updateFromStampTextProvider(stampTextProvider);
                print("Selected font size: $selectedFontSize");
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
          ),
        );
      },
    );
  }

  ///
}
