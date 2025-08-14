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
    return SizedBox(
      width: 60.w,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: Colors.transparent, // 🚫 removes click highlight
        ),
        onPressed: onTap,
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
