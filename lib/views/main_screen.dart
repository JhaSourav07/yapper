import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/main_controller.dart';
import 'package:yapper/views/chats_list_view.dart';
import 'package:yapper/views/find_people_screen.dart';
import 'package:yapper/views/friends_screen.dart';
import 'package:yapper/views/profile/profile_screen.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep obsidian
      body: Stack(
        children: [
          // Global mesh background (subtle)
          Positioned.fill(
            child: CustomPaint(
              painter: MainBackgroundMeshPainter(),
            ),
          ),
          
          // Page Content
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            physics: const NeverScrollableScrollPhysics(), // Controlled via BottomNav
            children: const [
              ChatsListView(),
              FriendsScreen(),
              FindPeopleScreen(),
              ProfileScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildTechnicalBottomNav(),
    );
  }

  Widget _buildTechnicalBottomNav() {
    return Obx(() => Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF08080A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF22D3EE).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.chat_bubble_outline_rounded, "CHATS", hasBadge: true),
          _buildNavItem(1, Icons.people_outline_rounded, "MESH"),
          _buildNavItem(2, Icons.radar_rounded, "DISCOVER"),
          _buildNavItem(3, Icons.person_outline_rounded, "IDENTITY"),
        ],
      ),
    ));
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool hasBadge = false}) {
    final isSelected = controller.currentIndex == index;
    final color = isSelected ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.3);

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTabIndex(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (hasBadge && controller.getUnreadCount() > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22D3EE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22D3EE).withOpacity(0.4),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${controller.getUnreadCount()}',
                        style: const TextStyle(color: Color(0xFF08080A), fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              width: isSelected ? 12 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF22D3EE),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22D3EE).withOpacity(0.5),
                    blurRadius: 4,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderView(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, color: const Color(0xFF22D3EE).withOpacity(0.2), size: 40),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class MainBackgroundMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.02)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    // Draw a subtle grid/mesh
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}