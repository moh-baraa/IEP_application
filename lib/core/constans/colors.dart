import 'package:flutter/material.dart';

abstract class AppColorScheme {
  Color get primary;
  Color get background;
  Color get secondary;
  Color get text;
  Color get secText;
  Color get secTextShapes;
  Color get red;
  Color get blue;
  Color get green;
  Color get orange;
  Color get button;
  Color get container;
  Color get bg;
}

//Light theme
class LightColorScheme extends AppColorScheme {
  @override
  Color get primary => const Color(0xFF2F5496);

  @override
  Color get background => const Color(0xFFFFFFFF);

  @override
  Color get secondary => const Color(0xffc0d6fe);
  //d5ddea
  @override
  Color get text => const Color(0xFF000000);

  @override
  Color get secText => const Color(0xFF9a9a9a);
  //5b6270
  @override
  Color get secTextShapes => AppColors.light.secText.withOpacity(0.4);

  @override
  Color get red => const Color(0xFFFF6347);

  @override
  Color get blue => const Color(0xFF0051FF);

  @override
  Color get green => const Color(0xFF4CAF50);

  @override
  Color get orange => const Color(0xFFFF9800);

  @override
  Color get button => const Color(0xFFd9d9d9);

  @override
  Color get container => const Color(0xFFe4e4e4);
  @override
  Color get bg => const Color(0xFFF5F7FA);
}

//Dark theme
// class DarkColorScheme extends AppColorScheme {
//   @override
//   Color get primary => const Color(0xFFFFEA53);

//   @override
//   Color get background => const Color(0xFF101010);

//   @override
//   Color get secondary => const Color(0xFF1F1F1F);

//   @override
//   Color get text => const Color(0xFFFFFFFF);

//   @override
//   Color get secText => const Color(0xFF534D52);

//   @override
//   Color get red => const Color(0xFFFF7043);

//   @override
//   Color get blue => const Color(0xFF0051FF);

//   @override
//   Color get green => const Color(0xFF66BB6A);

//   @override
//   Color get orange => const Color(0xFFFFCA28);

//   @override
//   Color get button => const Color(0xFFFF9800);

//   @override
//   Color get container => const Color(0xFFFF9800);
// }

class AppColors {
  static final AppColorScheme light = LightColorScheme();
  // static final AppColorScheme dark = DarkColorScheme();
}
