import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

extension Material3Palette on Color {
  /// The tone of a color is a percentage value between 0 and 100.
  /// The lower the tone of a color, the darker the color appears
  /// and as it approach 0, the color becomes black.
  /// The higher the tone of a color, the lighter the color appears
  /// and as it approach 100, the color becomes white.
  Color tone(int tone) {
    assert(tone >= 0 && tone <= 100);
    final color = Hct.fromInt(value);
    final tonalPalette = TonalPalette.of(color.hue, color.chroma);
    return Color(tonalPalette.get(tone));
  }

  /// Saturation is a percentage value between 0 and 100.
  /// The lower the saturation of a color, the more faded or dull the color appears.
  /// like pastel colors, like pale colors, like washed out colors, like muted colors.
  /// The higher the saturation of a color, the more vivid or intense the color appears.
  Color saturation(double saturation) {
    assert(saturation >= 0 && saturation <= 100);
    return HSLColor.fromColor(this).withSaturation(saturation / 100).toColor();
  }
}
