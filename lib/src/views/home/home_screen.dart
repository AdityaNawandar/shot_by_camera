import 'package:flutter/material.dart';
import 'package:photo_stamp/src/providers/photo_provider.dart';
import 'package:photo_stamp/src/providers/stamp_text_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/stamp_text_config.dart';

class HomeScreen extends StatelessWidget {
  // HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ///
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final stampProvider =
        Provider.of<StampTextProvider>(context, listen: false);
    // Immediately update PhotoProvider with the current values from StampTextProvider
    photoProvider.updateFromStampTextProvider(stampProvider);

    ///
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StampTextConfig(
          onColorSelect: (color) {
            stampProvider.setFontColor(color);
            photoProvider.updateFromStampTextProvider(
                stampProvider); // Update PhotoProvider
          },
          onFontSizeChange: (size) {
            stampProvider.setFontSize(size);
            photoProvider.updateFromStampTextProvider(
                stampProvider); // Update PhotoProvider
          },
          onPositionSelect: (position) {
            if (position != null) {
              stampProvider.setTextPosition(position);
              photoProvider.updateFromStampTextProvider(
                  stampProvider); // Update PhotoProvider
            }
          },
        ),
      ),
    );
  }
}
