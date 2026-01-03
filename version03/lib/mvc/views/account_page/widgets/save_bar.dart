import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/account_page/account_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';

class AppSaveBar extends StatelessWidget {
  const AppSaveBar({
    super.key,
    required this.context,
    required this.controller,
    required this.userProvider,
  });
  final BuildContext context;
  final AccountController controller;
  final UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Do you want to save changes?',
              style: AppTextStyles.size14weight4(AppColors.light.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 26),
            onPressed: () => controller.cancelChanges(userProvider),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.light.primary,
              shape: BoxShape.circle,
            ),
            child: controller.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      // === more protection ===
                      if (userProvider.user != null) {
                        controller.saveChanges(
                          context,
                          userProvider,userProvider.currentUser!
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
