import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class FlagCircle extends StatelessWidget {
  const FlagCircle({super.key, required this.flagCode, this.size = 40});

  final String flagCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CountryFlag.fromCountryCode(
      flagCode.toUpperCase(),
      theme: ImageTheme(
        width: size,
        height: size,
        shape: const Circle(),
      ),
    );
  }
}
