import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/models/chat_model.dart';
import 'package:yapper/models/user_model.dart';
import 'package:yapper/routes/app_routes.dart';
import 'package:yapper/services/firestore_service.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({super.key});

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) {
      return const Center(child: Text("NOT AUTHENTICATED", style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "COMMUNICATIONS CORE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF22D3EE),
              size: 22,
            ),
            tooltip: "Notifications",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _firestoreService.getUserChatsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "SIGNAL ERROR: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            );
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "NO ACTIVE CHATS",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover nodes in the directory to start a chat",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              return FutureBuilder<UserModel?>(
                future: _firestoreService.getUser(otherUserId),
                builder: (context, userSnapshot) {
                  final targetUser = userSnapshot.data;
                  final displayName = targetUser?.displayName ?? 'NODE...';
                  final isOnline = targetUser?.isOnline ?? false;
                  final unreadCount = chat.getUnreadCount(currentUserId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                      onTap: () {
                        if (targetUser != null) {
                          Get.toNamed(
                            AppRoutes.chat,
                            arguments: {
                              'chatId': chat.id,
                              'targetUser': targetUser,
                            },
                          );
                        }
                      },
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF22D3EE).withValues(alpha: 0.15),
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'N',
                              style: const TextStyle(
                                color: Color(0xFF22D3EE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22D3EE),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF08080A), width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        displayName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      subtitle: Text(
                        chat.lastMessage ?? "NO MESSAGES",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (chat.lastMessageTime != null)
                            Text(
                              _formatTime(chat.lastMessageTime!),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 10,
                              ),
                            ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22D3EE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "$unreadCount",
                                style: const TextStyle(
                                  color: Color(0xFF08080A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
