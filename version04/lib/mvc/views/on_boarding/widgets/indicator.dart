import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
final colors = AppColors.light;
class Indicator extends StatelessWidget {
  const Indicator({super.key, required this.pageNumber});
  final int pageNumber;
  
  @override
  Widget build(BuildContext context) {

    Widget indicatorCircle(bool active){
      return  Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: active ? colors.primary : colors.secondary,
        shape: BoxShape.circle,
      ),
    );
    }

    return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                indicatorCircle( pageNumber==1),
                const SizedBox(width: 10),
                indicatorCircle( pageNumber==2),
                const SizedBox(width: 10),
                indicatorCircle( pageNumber==3),
              ],
            );
  }
}

            