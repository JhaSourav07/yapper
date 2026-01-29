import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logic remains exactly as provided
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep obsidian
      body: Stack(
        children: [
          // Background Mesh Effect (Originating from top-left for variation)
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: ForgotMeshPainter(
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
                    const SizedBox(height: 60),

                    // Technical Header Icon with enhanced glow
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF22D3EE).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.restart_alt_rounded,
                          color: Color(0xFF22D3EE),
                          size: 56,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Typography
                    Text(
                      "SECURITY RECOVERY",
                      style: TextStyle(
                        color: const Color(0xFF22D3EE).withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "FORGOT KEY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Provide your registered node identity to initialize the key recovery protocol.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Technical Email Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "NODE IDENTITY (EMAIL)",
                              style: TextStyle(
                                color: const Color(0xFF22D3EE).withOpacity(0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Icon(
                              Icons.verified_user_outlined,
                              size: 14,
                              color: const Color(0xFF22D3EE).withOpacity(0.4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
                          cursorColor: const Color(0xFF22D3EE),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'REQUIRED';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'INVALID FORMAT';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "node@mesh.network",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),
                            prefixIcon: Icon(Icons.alternate_email_rounded, 
                                color: Colors.white.withOpacity(0.3), size: 20),
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
                    ),

                    const SizedBox(height: 32),

                    // Reset Button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : controller.sendPasswordResetEmail,
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
                                "SEND RECOVERY LINK",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    )),

                    const SizedBox(height: 24),

                    // Spam Folder Notice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22D3EE).withOpacity(0.03),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF22D3EE).withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: const Color(0xFF22D3EE).withOpacity(0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "NOTE: If the transmission is not visible in your inbox within 5 minutes, please check your SPAM or JUNK folders.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Error Message Display
                    Obx(() => controller.error.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: Text(
                              controller.error.toUpperCase(),
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

                    // Back to Login
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: RichText(
                            text: TextSpan(
                              text: "REMEMBERED ACCESS? ",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              children: const [
                                TextSpan(
                                  text: "ACCESS CORE",
                                  style: TextStyle(
                                    color: Color(0xFF22D3EE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotMeshPainter extends CustomPainter {
  final double rotation;

  ForgotMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.04)
      ..strokeWidth = 0.5;

    final center = const Offset(0, 0); // Top-left origin
    const nodes = 12;
    final radius = size.width * 0.9;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (rotation * 0.2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(Offset(x, y), center, paint);
      
      final nextAngle = ((i + 1) * 2 * math.pi / nodes) + (rotation * 0.2 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ForgotMeshPainter oldDelegate) => true;
}