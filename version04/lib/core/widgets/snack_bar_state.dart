import 'package:flutter/material.dart';

class AppSnackBarState {
  static void show(
    BuildContext context, {
    required color,
    required String content,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }

}
