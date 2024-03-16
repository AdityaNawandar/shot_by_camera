import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_text_provider.dart';

class ColorPickerWidget extends StatelessWidget {
  ///
  final List<Color> colors = [
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pinkAccent,
    Colors.indigo,
    Colors.brown,
  ];

  ///
  final void Function(Color) onColorSelect;

  ///
  ColorPickerWidget({super.key, required this.onColorSelect});

  ///
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Font Color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Use Consumer to rebuild when fontColor changes
        Consumer<StampTextProvider>(
          builder: (context, stampProvider, child) {
            return GridView.count(
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 5,
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Add this to prevent scrolling within GridView
              children: colors.map((color) {
                // Determine if this color is selected based on the provider's fontColor
                bool isSelected = color.value == stampProvider.fontColor.value;
                //
                return GestureDetector(
                  onTap: () => onColorSelect(color),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: color == Colors.white
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: CircleAvatar(
                      backgroundColor: color,
                      child: isSelected
                          ? Icon(
                              Icons.done,
                              color: color == Colors.black
                                  ? Colors.white
                                  : Colors.black,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  ///
}
