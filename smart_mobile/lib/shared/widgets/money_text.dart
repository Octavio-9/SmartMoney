import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_money/core/theme/app_colors.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.color,
  });

  final double amount;
  final String currency;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0.##', 'fr_FR').format(amount);
    return Text(
      '$formatted $currency',
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: color ?? AppColors.text,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
