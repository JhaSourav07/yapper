import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final controller = Get.put(ProfileController());
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
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
      backgroundColor: const Color(0xFF08080A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        ),
        title: const Text(
          "NODE PROFILE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () {
                        if (controller.isEditing) {
                          controller.updateProfile();
                        } else {
                          controller.toggleEditing();
                        }
                      },
                child: Text(
                  controller.isEditing ? "SAVE" : "EDIT",
                  style: TextStyle(
                    color: controller.isEditing ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Mesh
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: ProfileMeshPainter(rotation: _rotationController.value),
                size: Size.infinite,
              );
            },
          ),

          Obx(() {
            final user = controller.currentUser;
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Profile Identity Core
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse-like rings
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        // Avatar Core
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withOpacity(0.3),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.2),
                                const Color(0xFFA855F7).withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF22D3EE),
                            size: 50,
                          ),
                        ),
                        // Online Status Indicator
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: user.isOnline ? const Color(0xFF22C55E) : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF08080A), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: (user.isOnline ? const Color(0xFF22C55E) : Colors.grey).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // User Info Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          user.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Online/Offline Status Label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: (user.isOnline ? const Color(0xFF22C55E) : Colors.white).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (user.isOnline ? const Color(0xFF22C55E) : Colors.white).withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: user.isOnline ? const Color(0xFF22C55E) : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.isOnline ? "NODE ACTIVE" : "NODE OFFLINE",
                                style: TextStyle(
                                  color: user.isOnline ? const Color(0xFF22C55E) : Colors.white.withOpacity(0.5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.getJoinedData().toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Data Fields
                  _buildTechnicalField(
                    label: "IDENTIFICATION STRING",
                    controller: controller.displayNameController,
                    icon: Icons.badge_outlined,
                    enabled: controller.isEditing,
                  ),

                  const SizedBox(height: 24),

                  _buildTechnicalField(
                    label: "NETWORK ADDRESS (EMAIL)",
                    controller: controller.emailController,
                    icon: Icons.alternate_email_rounded,
                    enabled: false, 
                  ),

                  const SizedBox(height: 48),

                  // System Command Buttons
                  Text(
                    "SYSTEM COMMANDS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSystemButton(
                    label: "CHANGE ACCESS KEY",
                    icon: Icons.vpn_key_outlined,
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    onTap: () {
                      // Logic for change password (usually forgot password route or a new screen)
                      Get.toNamed(AppRoutes.changePassword);
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSystemButton(
                    label: "SIGNOUT",
                    icon: Icons.logout_rounded,
                    color: Colors.white.withOpacity(0.05),
                    onTap: controller.signOut,
                  ),

                  const SizedBox(height: 12),

                  _buildSystemButton(
                    label: "TERMINATE IDENTITY",
                    icon: Icons.delete_forever_rounded,
                    color: Colors.redAccent.withOpacity(0.1),
                    textColor: Colors.redAccent,
                    onTap: controller.deleteAccount,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          }),

          // Loading Overlay
          Obx(() => controller.isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildTechnicalField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF22D3EE).withOpacity(enabled ? 0.8 : 0.4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
            fontSize: 16,
            letterSpacing: 1,
          ),
          cursorColor: const Color(0xFF22D3EE),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? const Color(0xFF22D3EE).withOpacity(0.6) : Colors.white.withOpacity(0.2),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.02),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: const Color(0xFF22D3EE).withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF22D3EE), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color textColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor.withOpacity(0.7), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}

class ProfileMeshPainter extends CustomPainter {
  final double rotation;

  ProfileMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22D3EE).withOpacity(0.03)
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height * 0.3);
    const nodes = 15;
    final radius = size.width * 0.6;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (rotation * 0.1 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 1.5, paint);
      
      final nextAngle = ((i + 1) * 2 * math.pi / nodes) + (rotation * 0.1 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
      
      // Secondary lines to create a mesh
      if (i % 3 == 0) {
        // Create a temporary paint with lower alpha for center lines
        final centerLinePaint = Paint()
          ..color = paint.color.withAlpha(10)
          ..strokeWidth = paint.strokeWidth;
        canvas.drawLine(Offset(x, y), center, centerLinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ProfileMeshPainter oldDelegate) => true;
}