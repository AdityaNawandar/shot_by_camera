import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../src/utils/app_constants.dart';
import '../providers/stamp_text_provider.dart';

class FontFamilySelectorWidget extends StatelessWidget {
  const FontFamilySelectorWidget(
      {super.key, required void Function(String newFont) onFontFamilySelected});

  ///
  TextStyle getFontStyle(String fontName) {
    switch (fontName) {
      case 'Roboto':
        return const TextStyle(fontFamily: 'Roboto');
      case 'Dancing Script Regular':
        return const TextStyle(fontFamily: 'Dancing Script Regular');
      case 'Exo 2 Italic':
        return const TextStyle(fontFamily: 'Exo 2 Italic');
      // Add more cases for each font
      default:
        return const TextStyle(); // Default style if font not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StampTextProvider>(
      builder: (context, provider, child) {
        return //
            SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Font',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonHideUnderline(
                // This widget hides the underline
                child: DropdownButton<String>(
                  isExpanded:
                      true, // Make the dropdown button expand to fill the container
                  value: provider.fontName ?? AppConstants.availableFonts.first,
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  elevation: 16,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  onChanged: (String? newValue) {
                    provider.fontName = newValue!;
                    print("Font Family changed to: $newValue");
                  },
                  items: AppConstants.availableFonts
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: getFontStyle(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///
}
