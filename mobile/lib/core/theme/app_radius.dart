import 'package:flutter/material.dart';

/// Radios de border de la app. Consistencia visual — siempre usar uno de estos.
abstract final class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  // Atajos prefab para no repetir codigo
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));

  /// Bottom sheets — solo redondeados arriba
  static const BorderRadius brBottomSheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
