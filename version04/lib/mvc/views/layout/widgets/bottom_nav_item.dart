import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';

AppColorScheme colors = AppColors.light;
class BottomNavItem {

static BottomNavigationBarItem add(IconData icon, String label, bool selected){
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? colors.secondary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
      label: label,
    );
}
}

