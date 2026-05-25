import 'package:flutter/material.dart';
import 'package:cxc/features/docs/view/pages/models_info_page.dart';
import 'package:cxc/features/auth/view/pages/profile_page.dart';
import 'package:cxc/features/prediction/view/pages/batch_prediction_page.dart';
import 'package:cxc/features/prediction/view/pages/dashboard_page.dart';
import 'package:cxc/shared/responsive/responsive_helper.dart';
import 'package:cxc/shared/widgets/persistent_top_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int selectedIndex;
  final GlobalKey<DashboardPageState> dashboardKey =
      GlobalKey<DashboardPageState>();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    pages = [
      DashboardPage(key: dashboardKey),
      const SizedBox.shrink(), // Placeholder for Camera
      const BatchPredictionPage(),
      const ModelsInfoPage(),
      const ProfilePage(),
    ];
  }

  void onItemTapped(int index) {
    if (index == 1) {
      // If Camera is tapped, we stay on Dashboard but trigger camera
      setState(() {
        selectedIndex = 0;
      });
      dashboardKey.currentState?.handleImageSelection(fromCamera: true);
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCameraItem = ResponsiveHelper.isPlatformMobile();

    return Scaffold(
      body: Column(
        children: [
          PersistentTopNav(
            items: [
              PersistentTopNavItem(
                label: 'Home',
                icon: Icons.home_rounded,
                isActive: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
              if (showCameraItem)
                PersistentTopNavItem(
                  label: 'Camera',
                  icon: Icons.camera_alt_rounded,
                  isActive: false,
                  onTap: () => onItemTapped(1),
                ),
              PersistentTopNavItem(
                label: 'Batch',
                icon: Icons.layers_rounded,
                isActive: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
              PersistentTopNavItem(
                label: 'Docs',
                icon: Icons.library_books_rounded,
                isActive: selectedIndex == 3,
                onTap: () => onItemTapped(3),
              ),
              PersistentTopNavItem(
                label: 'Profile',
                icon: Icons.person_rounded,
                isActive: selectedIndex == 4,
                onTap: () => onItemTapped(4),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
        ],
      ),
    );
  }
}
