import 'package:flutter/material.dart';
import '../config/localization.dart';

class RTLWrapper extends StatelessWidget {
  final String languageCode;
  final Widget child;

  const RTLWrapper({
    super.key,
    required this.languageCode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = AppLocalization.isRTL(languageCode);
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }
}
