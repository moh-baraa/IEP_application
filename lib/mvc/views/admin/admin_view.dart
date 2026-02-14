import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/admin/admin_reports_controller.dart';
import 'package:iep_app/mvc/controllers/admin/projects_manager_controller.dart';
import 'package:iep_app/mvc/controllers/notification/notification_controller.dart';
import 'package:iep_app/mvc/views/admin/admin_notifications_page.dart';
import 'package:iep_app/mvc/views/admin/project_requests_page.dart';
import 'package:iep_app/mvc/views/admin/projects_manager_view.dart';
import 'package:iep_app/mvc/views/admin/reports_page.dart';
import 'package:iep_app/mvc/views/admin/users_manager_view.dart';
import 'package:iep_app/mvc/views/admin/widgets/admin_dashboard_card.dart';
import 'package:iep_app/mvc/views/auth/login_page.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/account_page/account_page.dart';

AppColorScheme colors = AppColors.light;

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final userProvider = UserProvider.instance;
  final controller = AdminReportsController();
  final notiController = NotificationController();
  final projController = ProjectsManagerController();

  @override
  void dispose() {
    super.dispose();
    projController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === check if the user is admin or municipality member ===
    final bool isMunicipality = userProvider.isMunicipality;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === admin functions list ===
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1, // height to width ratio
                  children: [
                    // === projects management card ===
                    AdminDashboardCard(
                      context: context,
                      title: "Manager",
                      icon: Icons.folder_special_outlined,
                      color: colors.primary,
                      count: "Projects",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                shape: Border(
                                  bottom: BorderSide(color: colors.secText),
                                ),
                                backgroundColor: colors.background,
                                title: Text(
                                  'Projects Manager',
                                  style: AppTextStyles.size18weight5(
                                    colors.text,
                                  ),
                                ),
                                centerTitle: true,
                              ),
                              body: ProjectsManagerView(),
                            ),
                          ),
                        );
                      },
                    ),

                    // === report management card ===
                    StreamBuilder<QuerySnapshot>(
                      stream: controller.getReportsStream(),
                      builder: (context, snapshot) {
                        String count = "...";
                        if (snapshot.hasData) {
                          count = snapshot.data!.docs.length.toString();
                        }
                        return AdminDashboardCard(
                          context: context,
                          title: "Reports",
                          icon: Icons.report_problem_outlined,
                          color: colors.red,
                          count: count,
                          isAlert:
                              snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminReportsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // === admin notification card ===
                    StreamBuilder<QuerySnapshot>(
                      stream: notiController.getAdminUnreadCount(),
                      builder: (context, snapshot) {
                        String countText = "0";
                        bool hasNew = false;

                        if (snapshot.hasData) {
                          int count = snapshot.data!.docs.length;
                          if (count > 0) {
                            countText = count.toString();
                            hasNew = true;
                          }
                        }
                        return AdminDashboardCard(
                          context: context,
                          title: "Notifications",
                          icon: hasNew
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          // === change to red color, if new ===
                          color: hasNew ? Colors.red : Colors.grey,
                          count: countText,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminNotificationsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // === profile page card ===
                    AdminDashboardCard(
                      context: context,
                      title: "Page",
                      icon: Icons.person,
                      color: Colors.grey,
                      count: "Profile",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              backgroundColor: colors.bg,
                              appBar: AppBar(
                                backgroundColor: colors.bg,
                                shape: Border(
                                  bottom: BorderSide(color: colors.secText),
                                ),
                                title: Text(
                                  'Profile',
                                  style: AppTextStyles.size18weight5(
                                    colors.text,
                                  ),
                                ),
                                centerTitle: true,
                              ),
                              body: AccountPage(),
                            ),
                          ),
                        );
                      },
                    ),

                    // === project Requests card ===
                    StreamBuilder<QuerySnapshot>(
                      stream: projController.getProjectRequestsStream(),
                      builder: (context, snapshot) {
                        String countText = "0 Requests";
                        bool hasRequests = false;

                        if (snapshot.hasData) {
                          int count = snapshot.data!.docs.length;
                          if (count > 0) {
                            countText = "$count Requests";
                            hasRequests = true;
                          }
                        }
                        return AdminDashboardCard(
                          context: context,
                          title: "Project Requests",
                          icon: Icons.playlist_add_check,
                          color: hasRequests ? colors.orange : Colors.grey,
                          count: countText,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProjectRequestsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // === users mangement card===
                    isMunicipality // not athourized to municipality member
                        ? SizedBox()
                        : AdminDashboardCard(
                            context: context,
                            title: "Maneger",
                            icon: Icons.people_outline,
                            color: Colors.orange,
                            count: "Users",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManageUsersPage(),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 10),

              // === logout button ===
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: Text(
                  'Sign Out',
                  style: AppTextStyles.size16weight6(colors.red),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.red,
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
      ),
    );
  }
}
