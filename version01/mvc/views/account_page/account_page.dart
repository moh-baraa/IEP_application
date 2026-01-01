import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/account_page/account_controller.dart';
import 'package:iep_app/mvc/views/account_page/widgets/editable_feild.dart';
import 'package:iep_app/mvc/views/account_page/widgets/save_bar.dart';
import 'package:iep_app/mvc/views/auth/login_page.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountController(),
      child: const _AccountPageView(),
    );
  }
}

class _AccountPageView extends StatefulWidget {
  const _AccountPageView();

  @override
  State<_AccountPageView> createState() => _AccountPageViewState();
}

class _AccountPageViewState extends State<_AccountPageView> {
  late final AccountController controller;
  @override
  void initState() {
    super.initState();

    // === read , build only one time, good for initState ===
    final userProvider = context.read<UserProvider>();
    controller = context.read<AccountController>();

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
    final userProvider = context.watch<UserProvider>();
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                // === image section ===
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    SizedBox(height: 40),
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: controller.localImageFile != null
                          ? FileImage(controller.localImageFile!)
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
                  onEditTap: () => controller.toggleEdit('email'),
                  colors: colors,
                ),

                // === buttons section ===
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Change Password',
                    style: AppTextStyles.size16weight5(AppColors.light.primary),
                  ),
                ),
                const SizedBox(height: 40),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: Text(
                    'Sign out',
                    style: AppTextStyles.size16weight4(AppColors.light.text),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                    AppSnackBarState.show(
                      context,
                      color: colors.secText,
                      content: 'Signed out seccussfully!',
                    );
                  },
                ),
              ],
            ),
          ),
          // === save bar ===
          if (controller.showSaveBar)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: AppSaveBar(
                context: context,
                controller: controller,
                userProvider: userProvider,
              ),
            ),
        ],
      ),
    );
  }
}
