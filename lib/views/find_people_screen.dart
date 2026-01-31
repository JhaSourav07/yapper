import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/users_list_controller.dart';
// import 'package:yapper/views/widgets/user_list_item.dart'; // Replaced with local widget
import 'package:yapper/models/user_model.dart'; // Added for UserListItem
import 'dart:math' as math;

class FindPeopleScreen extends StatefulWidget {
  const FindPeopleScreen({super.key});

  @override
  State<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends State<FindPeopleScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  final UsersListController controller = Get.put(UsersListController());

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by MainScreen background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "GLOBAL NODE DIRECTORY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Local Mesh Animation (Overlaying main screen mesh for depth)
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: DiscoverMeshPainter(rotation: _rotationController.value),
                size: Size.infinite,
              );
            },
          ),

          Column(
            children: [
              // Search Bar Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF22D3EE).withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                ),
                child: TextField(
                  controller: controller.searchController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                  cursorColor: const Color(0xFF22D3EE),
                  decoration: InputDecoration(
                    hintText: "SEARCH NODES...",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF22D3EE).withOpacity(0.5),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF22D3EE).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Users List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.filteredUsers.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF22D3EE).withOpacity(0.5),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (controller.filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_search_rounded,
                            color: Colors.white.withOpacity(0.1),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "NO NODES FOUND IN RANGE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: controller.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = controller.filteredUsers[index];
                      // Used local _UserListItem to include Cancel button logic explicitly
                      return _UserListItem(user: user, controller: controller);
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiscoverMeshPainter extends CustomPainter {
  final double rotation;

  DiscoverMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22D3EE).withOpacity(0.03) // Cyan tint for discover
      ..strokeWidth = 0.5;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    const nodes = 6; // Less nodes, wider spread
    final radius = size.width * 0.9;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (rotation * 0.05 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      // Draw radar-like sweep lines
      canvas.drawLine(center, Offset(x, y), paint);
      
      // Draw connecting perimeter
      final nextAngle = ((i + 1) * 2 * math.pi / nodes) + (rotation * 0.05 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DiscoverMeshPainter oldDelegate) => true;
}

// --- Local Widget for User List Item with Action Buttons ---

class _UserListItem extends StatelessWidget {
  final UserModel user;
  final UsersListController controller;

  const _UserListItem({
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.getRelationStatus(user.id);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.2),
                        const Color(0xFFA855F7).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF22D3EE).withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF22D3EE),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF08080A), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Action Button
            _buildActionButton(status),

            // More Options (Block / Cancel)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.5), size: 20),
              color: const Color(0xFF161618),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) {
                final List<PopupMenuEntry<String>> items = [];
                
                // Add Cancel option if request is pending
                if (status == UserRelationStatus.pendingSent) {
                  items.add(
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.7), size: 16),
                          const SizedBox(width: 12),
                          Text(
                            'CANCEL REQUEST',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Always add Block option
                items.add(
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        const Icon(Icons.block_rounded, color: Color(0xFFF43F5E), size: 16),
                        const SizedBox(width: 12),
                        Text(
                          'BLOCK NODE',
                          style: TextStyle(
                            color: const Color(0xFFF43F5E).withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                return items;
              },
              onSelected: (value) {
                if (value == 'block') {
                  controller.blockUser(user.id);
                } else if (value == 'cancel') {
                  controller.cancelFriendRequest(user.id);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton(UserRelationStatus status) {
    String label;
    Color color;
    Color textColor;
    VoidCallback? onTap;
    IconData icon;

    switch (status) {
      case UserRelationStatus.friend:
        label = "CHAT";
        color = const Color(0xFF22D3EE);
        textColor = const Color(0xFF08080A);
        icon = Icons.chat_bubble_outline_rounded;
        onTap = () => controller.startChat(user);
        break;
      
      case UserRelationStatus.pendingSent:
        label = "REQUEST SENT";
        color = Colors.white.withOpacity(0.05);
        textColor = Colors.white.withOpacity(0.5);
        icon = Icons.mark_email_read_outlined;
        onTap = () {}; // Non-interactive status indicator
        break;
        
      case UserRelationStatus.pendingReceived:
        label = "PENDING";
        color = const Color(0xFFA855F7).withOpacity(0.2);
        textColor = const Color(0xFFA855F7);
        icon = Icons.hourglass_empty_rounded;
        onTap = () {}; // Can add 'Accept' logic here if needed
        break;

      case UserRelationStatus.blocked:
         label = "BLOCKED";
         color = const Color(0xFFF43F5E).withOpacity(0.1);
         textColor = const Color(0xFFF43F5E);
         icon = Icons.block;
         onTap = () {};
         break;

      case UserRelationStatus.none:
      default:
        label = "ADD FRIEND";
        color = const Color(0xFF6366F1);
        textColor = Colors.white;
        icon = Icons.person_add_rounded;
        onTap = () => controller.sendFriendRequest(user);
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}