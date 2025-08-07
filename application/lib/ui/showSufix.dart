// lib/ui/show_hide_suffix.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowHideSuffix extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onTap;

  const ShowHideSuffix({
    super.key,
    required this.isVisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 60.w,
        child: Text(
          isVisible ? 'HIDE' : 'SHOW',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

  }
}
