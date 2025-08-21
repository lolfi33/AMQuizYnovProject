import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TimerWidget extends StatelessWidget {
  final ValueNotifier<double> progress;

  const TimerWidget({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, child) {
        return Container(
          width: 90.w,
          height: 10,
          margin: EdgeInsets.only(
            top: 1.h,
            left: 5.w,
            right: 5.w,
          ),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation(Color(0xff9c4fff)),
            value: value,
          ),
        );
      },
    );
  }
}
