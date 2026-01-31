import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/friends_controller.dart';
import 'dart:math' as math;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  final FriendsController controller = Get.put(FriendsController());

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
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
          "NODE MESH",
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
          // Background Mesh Animation
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: FriendsMeshPainter(rotation: _rotationController.value),
                size: Size.infinite,
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INCOMING REQUESTS SECTION ---
                  Obx(() {
                    if (controller.incomingRequests.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("INCOMING SIGNALS", controller.incomingRequests.length),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.incomingRequests.length,
                          itemBuilder: (context, index) {
                            final item = controller.incomingRequests[index];
                            return _buildRequestItem(item);
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }),

                  // --- FRIENDS LIST SECTION ---
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("ESTABLISHED LINKS", controller.friends.length),
                        const SizedBox(height: 16),
                        
                        if (controller.isLoadingFriends.value && controller.friends.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
                            ),
                          )
                        else if (controller.friends.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.hub_rounded, color: Colors.white.withOpacity(0.1), size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  "NO ACTIVE LINKS",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.friends.length,
                            itemBuilder: (context, index) {
                              final item = controller.friends[index];
                              return _buildFriendItem(item);
                            },
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Icon(Icons.share_location_rounded, color: const Color(0xFF22D3EE).withOpacity(0.5), size: 14),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF22D3EE).withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF22D3EE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Color(0xFF22D3EE),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRequestItem(RequestWithUser item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    item.user.displayName.isNotEmpty ? item.user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.user.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "REQUESTING ACCESS...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.declineRequest(item.request.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "DECLINE",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => controller.acceptRequest(item.request.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "ACCEPT LINK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(FriendWithUser item) {
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
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF22D3EE).withOpacity(0.1),
                      const Color(0xFFA855F7).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    item.user.displayName.isNotEmpty ? item.user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF22D3EE),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              if (item.user.isOnline)
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.user.isOnline ? "NODE ACTIVE" : "OFFLINE",
                  style: TextStyle(
                    color: item.user.isOnline ? const Color(0xFF10B981) : Colors.white.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.startChat(item.user),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
              padding: const EdgeInsets.all(10),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF22D3EE), size: 20),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.3), size: 20),
            color: const Color(0xFF161618),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.person_remove_rounded, color: Color(0xFFF43F5E), size: 16),
                    const SizedBox(width: 12),
                    Text(
                      'UNLINK NODE',
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
              if (value == 'remove') {
                controller.removeFriend(item.user.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class FriendsMeshPainter extends CustomPainter {
  final double rotation;

  FriendsMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22D3EE).withOpacity(0.02)
      ..strokeWidth = 0.5;

    final center = Offset(size.width * 0.8, size.height * 0.2); // Top right focus
    const nodes = 8;
    final radius = size.width * 0.7;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (rotation * 0.1 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(x, y), paint);
      
      for (var j = 0; j < nodes; j++) {
         if (i == j) continue;
         // Draw subtle connections between nodes
         final angle2 = (j * 2 * math.pi / nodes) + (rotation * 0.1 * math.pi);
         final x2 = center.dx + radius * math.cos(angle2);
         final y2 = center.dy + radius * math.sin(angle2);
         if ((i - j).abs() == 1 || (i - j).abs() == nodes - 1) {
             canvas.drawLine(Offset(x, y), Offset(x2, y2), paint);
         }
      }
    }
  }

  @override
  bool shouldRepaint(covariant FriendsMeshPainter oldDelegate) => true;
}