import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/change_password_controller.dart';
import 'dart:math' as math;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  // Initialize controller outside of build for stability
  final ChangePasswordController controller = Get.put(ChangePasswordController());

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
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
          "SECURITY PROTOCOL",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
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
                painter: ChangePasswordMeshPainter(
                  rotation: _rotationController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF22D3EE).withOpacity(0.2),
                            width: 1,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          color: Color(0xFF22D3EE),
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Typography
                    Text(
                      "IDENTITY VALIDATION",
                      style: TextStyle(
                        color: const Color(0xFF22D3EE).withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "UPDATE ACCESS KEY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rotate your security credentials to maintain node integrity.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Current Password Field
                    Obx(() => _buildTechnicalField(
                      label: "CURRENT ACCESS KEY",
                      controller: controller.currentPasswordController,
                      icon: Icons.lock_outline_rounded,
                      obscureText: controller.obscureCurrentPassword,
                      onToggle: controller.toggleCurrentPasswordVisibility,
                      validator: controller.validateCurrentPassword,
                    )),

                    const SizedBox(height: 20),
                    
                    // Divider Line
                    Container(
                      height: 1,
                      width: 40,
                      color: const Color(0xFF22D3EE).withOpacity(0.1),
                    ),
                    const SizedBox(height: 20),

                    // New Password Field
                    Obx(() => _buildTechnicalField(
                      label: "NEW ACCESS KEY",
                      controller: controller.newPasswordController,
                      icon: Icons.security_rounded,
                      obscureText: controller.obscureNewPassword,
                      onToggle: controller.toggleNewPasswordVisibility,
                      validator: controller.validateNewPassword,
                    )),

                    const SizedBox(height: 20),

                    // Confirm Password Field
                    Obx(() => _buildTechnicalField(
                      label: "CONFIRM NEW KEY",
                      controller: controller.confirmPasswordController,
                      icon: Icons.verified_user_outlined,
                      obscureText: controller.obscureConfirmPassword,
                      onToggle: controller.toggleConfirmPasswordVisibility,
                      validator: controller.validateConfirmPassword,
                    )),

                    const SizedBox(height: 40),

                    // Submit Button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : controller.changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22D3EE),
                          foregroundColor: const Color(0xFF08080A),
                          disabledBackgroundColor: const Color(0xFF22D3EE).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF08080A),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "INITIALIZE ROTATION",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    )),

                    const SizedBox(height: 24),

                    // System Error Display
                    Obx(() => controller.error.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: Text(
                              controller.error,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF22D3EE).withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
          cursorColor: const Color(0xFF22D3EE),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.02),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF22D3EE), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }
}

class ChangePasswordMeshPainter extends CustomPainter {
  final double rotation;

  ChangePasswordMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.04)
      ..strokeWidth = 0.5;

    // Originating from bottom center
    final center = Offset(size.width / 2, size.height);
    const nodes = 10;
    final radius = size.width * 0.8;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 1.5 * math.pi / nodes) - (rotation * 0.2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(Offset(x, y), center, paint);
      
      final nextAngle = ((i + 1) * 1.5 * math.pi / nodes) - (rotation * 0.2 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ChangePasswordMeshPainter oldDelegate) => true;
}