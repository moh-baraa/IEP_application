import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/home_page/home_controller.dart';
import 'package:iep_app/mvc/controllers/home_page/saved_projects_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/home_page/widgets/dashboard_button.dart';
import 'package:iep_app/mvc/views/home_page/widgets/dashboard_button_container.dart';
import 'package:iep_app/mvc/views/home_page/widgets/saved_projects_container.dart';
import 'package:iep_app/mvc/views/home_page/widgets/snapshot_card.dart';
import 'package:iep_app/mvc/views/home_page/widgets/snapshot_container.dart';
import 'package:provider/provider.dart';

AppColorScheme colors = AppColors.light;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SavedProjectsController savedController = SavedProjectsController();
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    savedController.fetchSavedProjects();
  }

  @override
  void dispose() {
    savedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          UserProvider.instance.refreshStats(), // تحديث الإحصائيات
          savedController.fetchSavedProjects(), // تحديث المشاريع المحفوظة
        ]);
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // important to do pull reload
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== welcome user section ====================
            Consumer<UserProvider>(
              builder: (context, provider, _) {
                return Text(
                  // === show the user name ,or unknown if there no user ===
                  'Welcome, ${provider.firstName ?? "User"}',
                  style: AppTextStyles.size26weight5(colors.text),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              },
            ),

            // ==================== welcome user section ====================
            const SizedBox(height: 20),

            // ==================== main actions button ====================
            AppDashboardContainer(
              buttons: [
                AppDashboardButton(
                  icon: Icons.add_circle_outline,
                  text: 'New Project',
                  onPressed: () => _controller.navigateToAddProject(context),
                ),

                AppDashboardButton(
                  icon: Icons.playlist_add_check_circle_outlined,
                  text: 'My Contracts',
                  onPressed: () => _controller.onMyContractsTap(context),
                ),
                AppDashboardButton(
                  icon: Icons.money_off_csred_outlined,
                  text: 'My Funds',
                  onPressed: () => _controller.onMyInvestmentsTap(context),
                ),

                AppDashboardButton(
                  icon: Icons.folder_copy_outlined,
                  text: 'My Projects',
                  onPressed: () => _controller.onMyProjectsTap(context),
                ),
              ],
            ),

            // ==================== main actions button ====================
            const SizedBox(height: 24),

            // ==================== Dashboard Snapshot ====================
            Consumer<UserProvider>(
              builder: (context, provider, _) {
                return AppSnapshotContainer(
                  cards: [
                    // === get the numbers from the provider, default will be 0 ===
                    AppSnapshotCard(
                      title: 'Recent Transactions',
                      number: provider.transactionsCount,
                    ),
                    AppSnapshotCard(
                      title: 'Active Projects',
                      number: provider.activeProjectsCount,
                    ),
                    AppSnapshotCard(
                      title: 'Investments & Donation',
                      number: provider.investmentsCount,
                    ),
                  ],
                );
              },
            ),

            // ==================== Dashboard Snapshot ====================
            const SizedBox(height: 24),

            // ==================== Saved Projects ====================
            SavedProjectsContainer(controller:savedController),
            // ==================== Saved Projects ====================
          ],
        ),
      ),
    );
  }
}
