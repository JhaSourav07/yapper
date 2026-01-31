import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/users_list_controller.dart';
import 'package:yapper/models/user_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final UsersListController controller;

  const UserListItem({
    super.key,
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
                    user.email, // Or obscure this if privacy is needed
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

            // More Options (Block)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.3), size: 20),
              color: const Color(0xFF161618),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
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
              ],
              onSelected: (value) {
                if (value == 'block') {
                  controller.blockUser(user.id);
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
    VoidCallback onTap;
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
        label = "CANCEL";
        color = Colors.white.withOpacity(0.1);
        textColor = Colors.white.withOpacity(0.7);
        icon = Icons.close_rounded;
        onTap = () => controller.cancelFriendRequest(user.id);
        break;
        
      case UserRelationStatus.pendingReceived:
        // Technically this list usually filters out incoming requests to a specific tab,
        // but if they appear, we can treat them as potential friends
        label = "PENDING";
        color = const Color(0xFFA855F7).withOpacity(0.2);
        textColor = const Color(0xFFA855F7);
        icon = Icons.hourglass_empty_rounded;
        onTap = () {}; // Maybe redirect to requests tab
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
        label = "ADD";
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