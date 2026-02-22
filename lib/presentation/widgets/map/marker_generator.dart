import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  /// Generates a custom BitmapDescriptor using a Flutter Icon
  static Future<BitmapDescriptor> createCustomMarker({
    required IconData iconData,
    required Color color,
    double size = 80.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 1. Draw the background circle with shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final Paint bgPaint = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, shadowPaint);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, bgPaint);

    // 2. Draw the inner circular background for the icon
    final Paint innerBgPaint = Paint()..color = color.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, innerBgPaint);

    // 3. Draw the icon
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size / 2,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    // 4. Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }
}
