import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/admin/widgets/admin_user_card.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:iep_app/mvc/views/project_page/widgets/catagories_list.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/admin/manage_users_controller.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late final ManageUsersController controller;
  @override
  void initState() {
    super.initState();
    controller = ManageUsersController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          'Manage Users',
          style: AppTextStyles.size18weight5(colors.text),
        ),
        backgroundColor: colors.background,
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 10),

                // === filter the user catagories ===
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: AppCatagoriesList(
                    categories: const [
                      'All',
                      'Users',
                      'Admins',
                      'Municipality',
                    ],
                    onSelected: (category) {
                      controller.filterUsers(category);
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // === users list ===
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.displayedUsers.isEmpty
                      ? AppUnFoundPage(text: "No users found")
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 5, bottom: 20),
                          itemCount: controller.displayedUsers.length,
                          itemBuilder: (context, index) {
                            var doc = controller.displayedUsers[index];
                            var data = doc.data() as Map<String, dynamic>;

                            String uid = doc.id;
                            String name =
                                "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}"
                                    .trim();

                            String email = data['email'] ?? "No Email";
                            String image = data['avatar_url'] ?? "";

                            var rawRole = data['role'];
                            String role = "user";
                            if (rawRole != null) {
                              role = rawRole.toString().trim().toLowerCase();
                            }

                            bool isBlocked = data['isBlocked'] ?? false;

                            return AdminUserCard(
                              name: name,
                              email: email,
                              avatarUrl: image,
                              role: role,
                              isBlocked: isBlocked,
                              onChatTap: () => controller.chatWithUser(
                                context,
                                uid,
                                name,
                                image,
                              ),
                              onBlockTap: () => controller.toggleBlockUser(
                                context,
                                uid,
                                isBlocked,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
