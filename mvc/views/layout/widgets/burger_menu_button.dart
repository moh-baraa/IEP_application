import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/views/layout/contactUs_page.dart';
import 'package:iep_app/mvc/views/layout/widgets/support_dialog.dart';

AppColorScheme colors = AppColors.light;
class BurgerMenuButton extends StatelessWidget {
  const BurgerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(//show elements in menu list
      icon: const Icon(Icons.menu),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'contact') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactUsPage()),
          );
        } else if (value == 'support') {
          AppSupportDialog.show(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'support',
          child: Text(
            'Support',
            style: AppTextStyles.size14weight4(colors.text),
          ),
        ),
        PopupMenuItem(
          value: 'contact',
          child: Text(
            'Contact Us',
            style: AppTextStyles.size14weight4(colors.text),
          ),
        ),
      ],
    );
  }
}
