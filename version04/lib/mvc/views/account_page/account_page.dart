import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/account_page/account_controller.dart';
import 'package:iep_app/mvc/views/account_page/widgets/editable_feild.dart';
import 'package:iep_app/mvc/views/account_page/widgets/save_bar.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountController controller;
  final userProvider = UserProvider.instance;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AccountController();
    userProvider
        .reloadUserData()
        .then((_) {
          if (!mounted) return;

          if (userProvider.user != null) {
            controller.initData(userProvider);
          }
        })
        .catchError((error) {
          debugPrint("Error reloading user data: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return ListenableBuilder(
      // === listen to changes on controller and user data ===
      listenable: Listenable.merge([controller, userProvider]),
      builder: (context, child) {
        if (userProvider.user != null) {
          // === update the feilds data ===
          controller.updateControllersIfReadOnly(userProvider);
        }

        return Scaffold(
          backgroundColor: colors.bg,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    // === image section ===
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        SizedBox(height: 40),
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: controller.localImageFile != null
                              ? (kIsWeb // to check is in browser or on phone image
                                        ? NetworkImage(
                                            controller.localImageFile!.path,
                                          )
                                        : FileImage(
                                            File(
                                              controller.localImageFile!.path,
                                            ),
                                          ))
                                    as ImageProvider
                              : (userProvider.avatarUrl != null &&
                                    userProvider.avatarUrl!.isNotEmpty)
                              ? NetworkImage(userProvider.avatarUrl!)
                              : const NetworkImage(
                                  'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                                ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 4, right: 4),
                          decoration: BoxDecoration(
                            color: AppColors.light.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: AppColors.light.background,
                              size: 18,
                            ),
                            onPressed: () => controller.pickImage(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // === name feild ===
                    AppEditableFeild(
                      label: "Full Name",
                      hint: "Enter your full name",
                      controller: controller.nameController,
                      isReadOnly: controller.isNameReadOnly,
                      onEditTap: () => controller.toggleEdit('name'),
                      colors: colors,
                    ),

                    const SizedBox(height: 16),

                    // === mobile feild ===
                    AppEditableFeild(
                      label: "Mobile Number",
                      hint: "079xxxxxxx",
                      controller: controller.phoneController,
                      isReadOnly: controller.isPhoneReadOnly,
                      inputType: TextInputType.phone,
                      onEditTap: () => controller.toggleEdit('phone'),
                      colors: colors,
                    ),

                    const SizedBox(height: 16),

                    // === email feild ===
                    AppEditableFeild(
                      label: "Email",
                      hint: "example@email.com",
                      controller: controller.emailController,
                      isReadOnly: controller.isEmailReadOnly,
                      inputType: TextInputType.emailAddress,
                      onEditTap: () =>
                          controller.toggleEdit('email'), // its stopped feature
                      colors: colors,
                      isEmail: true,
                    ),

                    // === buttons section ===
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => controller.forgetPassword(context),
                      child: controller.isForgetPassLoading
                          ? CircularProgressIndicator()
                          : Text(
                              'Change Password',
                              style: AppTextStyles.size16weight5(
                                AppColors.light.primary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 40),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 10),

                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: colors.red),
                      title: Text(
                        'Sign out',
                        style: AppTextStyles.size16weight4(AppColors.light.red),
                      ),
                      onTap: () => controller.signOut(context),
                    ),
                  ],
                ),
              ),
              // === save bar ===
              if (controller.showSaveBar)
                Positioned(
                  bottom: 60,
                  left: 20,
                  right: 20,
                  child: SafeArea(
                    child: AppSaveBar(
                      context: context,
                      controller: controller,
                      userProvider: userProvider,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
