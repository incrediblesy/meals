import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const seed = Color(0xFF356B45);
  static const lightBackground = Color(0xFFF8F9F5);
  static const darkBackground = Color(0xFF121611);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
  static const double wide = 1440;
  static const double maxContentWidth = 1200;
}
