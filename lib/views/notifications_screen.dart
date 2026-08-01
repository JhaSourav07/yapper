import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/notifications_controller.dart';
import 'package:yapper/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08080A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF22D3EE)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "SYSTEM NOTIFICATIONS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF22D3EE), size: 20),
            tooltip: "Mark all as read",
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE)));
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "NO RECENT NOTIFICATIONS",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            return _buildNotificationCard(item);
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    IconData icon;
    Color iconColor;

    switch (item.type) {
      case NotificationType.friendRequest:
        icon = Icons.person_add_rounded;
        iconColor = const Color(0xFF6366F1);
        break;
      case NotificationType.friendRequestAccepted:
        icon = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFF10B981);
        break;
      case NotificationType.friendRequestDeclined:
        icon = Icons.cancel_outlined;
        iconColor = const Color(0xFFF43F5E);
        break;
      case NotificationType.newMessage:
        icon = Icons.chat_bubble_outline_rounded;
        iconColor = const Color(0xFF22D3EE);
        break;
      case NotificationType.friendRemoved:
        icon = Icons.person_remove_rounded;
        iconColor = const Color(0xFFF43F5E);
        break;
    }

    return Dismissible(
      key: Key(item.id),
      onDismissed: (_) => controller.deleteNotification(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.white.withValues(alpha: 0.02)
              : const Color(0xFF22D3EE).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFF22D3EE).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        _formatTime(item.createdAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
