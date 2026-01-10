import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/account_page/account_page.dart';
import 'package:iep_app/mvc/views/admin/admin_view.dart';
import 'package:iep_app/mvc/views/chat_page/chat_page.dart';
import 'package:iep_app/mvc/views/home_page/home_page.dart';
import 'package:iep_app/mvc/views/layout/widgets/bottom_nav_item.dart';
import 'package:iep_app/mvc/views/layout/widgets/burger_menu_button.dart';
import 'package:iep_app/mvc/views/layout/widgets/notification_icon.dart';
import 'package:iep_app/mvc/views/project_page/projects_view.dart';

AppColorScheme colors = AppColors.light;

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  // === index for bottom nav & pages index ===
  int _currentIndex = 0;

  // === changing the index when this function calles by nav taping ===
  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // === use the provider to know is it normal user or is stuff(admin/municipality member) ===
    final userProvider = UserProvider.instance;
    final bool isStuff = userProvider.isAdmin || userProvider.isMunicipality;

    // === defined what is the forth page depending on who is the user(admin or...) ===
    // *if is it stuff will show -> AdminPage()
    // *if is it normal user will show -> AccountPage()
    final Widget forthPage = isStuff ? const AdminView() : const AccountPage();
    final String forthPageTitle = isStuff ? 'Admin Panel' : 'Profile';
    final IconData forthNavIcon = isStuff
        ? Icons.admin_panel_settings
        : Icons.person;
    final String forthNavLabel = isStuff ? "Admin" : "Profile";

    // === the body pages ===
    List<Widget> pages = [
      HomePage(),
      const ProjectsView(),
      ChatPage(),
      // === forth page changable ===
      forthPage,
    ];
    // === the pages title ===
    List<String> titles = [
      'I E P',
      'Projects',
      'Chat',
      // === forth page changable ===
      forthPageTitle,
    ];

    // === define how nav items looks + icon & name & index ===
    List<BottomNavigationBarItem> navItems = [
      BottomNavItem.add(Icons.home, "Home", _currentIndex == 0),
      BottomNavItem.add(Icons.folder, "Projects", _currentIndex == 1),
      BottomNavItem.add(Icons.chat, "Chat", _currentIndex == 2),
      // === forth page changable ===
      BottomNavItem.add(forthNavIcon, forthNavLabel, _currentIndex == 3),
    ];

    // === protection if the index become more than 3 ===
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: colors.bg,

      // ==================== app bar start ====================
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0, // removing app bar shadow
        scrolledUnderElevation:
            0, // disable flutter feature => app bar color changes in scrolling
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(color: colors.secText),
        ), // add bottom border to the app bar
        // === app bar Burger Menu ===
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: const Center(child: BurgerMenuButton()),
        ),

        // === app bar title ===
        title: Text(
          titles[_currentIndex],
          style: AppTextStyles.size18weight5(colors.text),
        ),

        // === app bar notification icon ===
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: const Center(child: NotificationButton()),
          ),
        ],
      ),
      // ==================== app bar end ====================

      // ==================== page content start ====================
      body: pages[_currentIndex],
      // ==================== page content end ====================

      // ==================== app bottom navBar start ====================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed, // fixed at bottom always
        backgroundColor: colors.primary,
        elevation: 0, // shadow
        selectedItemColor: colors.background,
        unselectedItemColor: colors.background.withOpacity(0.6),
        showUnselectedLabels: true,
        items: navItems,
      ),
      // ==================== app bottom navBar end ====================
    );
  }
}
