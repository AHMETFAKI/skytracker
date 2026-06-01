import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders the aircraft marker to PNG bytes at runtime so the app ships no
/// binary icon asset. The shape points north (up) at 0°, so the symbol layer's
/// `iconRotate = ['get','bearing']` aligns it to each flight's true track.
///
/// The glyph is drawn as a solid **white** silhouette and registered as an SDF
/// image (`addImage(..., true)`); that lets the symbol layer recolor each
/// aircraft per-altitude via an `iconColor` expression and add a contrasting
/// halo, instead of baking a single color into the bitmap.
Future<Uint8List> buildPlaneIcon({double size = 48, double scale = 3}) async {
  final dimension = size * scale;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final fill = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  // A simple arrow-plane silhouette in a unit square, nose pointing up.
  final w = dimension;
  final h = dimension;
  final path = Path()
    ..moveTo(w * 0.5, h * 0.08) // nose
    ..lineTo(w * 0.62, h * 0.55)
    ..lineTo(w * 0.92, h * 0.72) // right wingtip
    ..lineTo(w * 0.62, h * 0.70)
    ..lineTo(w * 0.58, h * 0.88)
    ..lineTo(w * 0.70, h * 0.95) // right tailplane
    ..lineTo(w * 0.50, h * 0.90)
    ..lineTo(w * 0.30, h * 0.95) // left tailplane
    ..lineTo(w * 0.42, h * 0.88)
    ..lineTo(w * 0.38, h * 0.70)
    ..lineTo(w * 0.08, h * 0.72) // left wingtip
    ..lineTo(w * 0.38, h * 0.55)
    ..close();

  canvas.drawPath(path, fill);

  final picture = recorder.endRecording();
  final image = await picture.toImage(dimension.toInt(), dimension.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
