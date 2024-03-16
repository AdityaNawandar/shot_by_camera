import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shotbycamera/src/utils/app_constants.dart';
import 'package:shotbycamera/src/widgets/color_picker.dart';
import 'package:shotbycamera/src/widgets/font_family_selector_widget.dart';
import 'package:shotbycamera/src/widgets/font_size_selector_widget.dart';
import 'package:shotbycamera/src/widgets/text_position_selector.dart';

import '../providers/stamp_text_provider.dart';
import 'title_text_widget.dart';

class StampTextConfig extends StatelessWidget {
  final void Function(Color) onColorSelect;
  final void Function(int) onFontSizeChange;
  final void Function(TextPosition) onTextPositionSelect;
  final void Function(String) onTextSubmit;

  ///
  const StampTextConfig({
    required this.onColorSelect,
    required this.onFontSizeChange,
    required this.onTextPositionSelect,
    required this.onTextSubmit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Input
          Consumer<StampTextProvider>(
            builder: (context, provider, child) {
              return TitleTextInputWidget(
                initialText: provider.text,
                onTextSubmit: provider.setText,
              );
            },
          ),
          const SizedBox(height: 16),

          // Font Size Selector - Assuming changes affect the provider
          Consumer<StampTextProvider>(
            builder: (context, provider, child) {
              return FontSizeSelectorWidget(
                selectedFontSize: provider.fontSize,
                onFontSizeSelected: provider.setFontSize,
              );
            },
          ),
          const SizedBox(height: 16),

          // Font Family Selector - Assuming it affects the provider
          Consumer<StampTextProvider>(
            builder: (context, provider, child) {
              return FontFamilySelectorWidget(
                onFontFamilySelected: provider.setFont,
              );
            },
          ),
          const SizedBox(height: 16),

          // Color Picker - Assuming changes affect the provider
          Consumer<StampTextProvider>(
            builder: (context, provider, child) {
              return ColorPickerWidget(
                onColorSelect: provider.setFontColor,
              );
            },
          ),
          const SizedBox(height: 16),

          // Text Position Selector - Assuming changes affect the provider
          Consumer<StampTextProvider>(
            builder: (context, provider, child) {
              return TextPositionSelectorWidget(
                selectedTextPosition: provider.textPosition,
                onTextPositionSelect: provider.setTextPosition,
              );
            },
          ),
          const SizedBox(height: 16),

          // Done Button
          Consumer<StampTextProvider>(
            builder: (context, provider, child) {
              return Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => onTextSubmit(
                    provider.textController?.text ?? AppConstants.defaultText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  ///
}
