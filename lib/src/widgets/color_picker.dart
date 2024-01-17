import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
    Colors.grey,
    Colors.black,
  ];

  final void Function(Color) onColorSelect;

  ColorPicker({required this.onColorSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, // space between adjacent chips
      runSpacing: 10, // space between lines
      children: colors.map((color) {
        return InkWell(
          onTap: () => onColorSelect(color),
          child: CircleAvatar(backgroundColor: color),
        );
      }).toList(),
    );
  }
}
