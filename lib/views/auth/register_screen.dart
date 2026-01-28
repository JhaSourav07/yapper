import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  
  late AnimationController _rotationController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _authController.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _displayNameController.text.trim(),
      );
      
      // After registration call completes, if the user is now authenticated,
      // redirect them to prevent them from being stuck on the splash screen
      // logic during the next reboot or hot restart.
      if (_authController.isAuthenticated) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        // If your controller logic doesn't auto-login, send them to login
        Get.snackbar(
          "SUCCESS",
          "Identity created. Please authenticate.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
          colorText: const Color(0xFF22D3EE),
        );
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep obsidian from Splash
      body: Stack(
        children: [
          // Background Mesh Effect
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: RegistrationMeshPainter(
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Technical Header Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF22D3EE).withOpacity(0.2),
                            width: 1,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF22D3EE).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF22D3EE),
                          size: 32,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Typography
                    Text(
                      "NEW NODE",
                      style: TextStyle(
                        color: const Color(0xFF22D3EE).withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "CREATE IDENTITY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Initialize your secure profile on the mesh.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Input Fields with Custom Technical Styling
                    _buildTechnicalField(
                      controller: _displayNameController,
                      label: "DISPLAY NAME",
                      hint: "Enter identification string",
                      icon: Icons.person_outline_rounded,
                      validator: (value) => (value == null || value.isEmpty) ? 'REQUIRED' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildTechnicalField(
                      controller: _emailController,
                      label: "SECURE EMAIL",
                      hint: "node@network.com",
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'REQUIRED';
                        if (!GetUtils.isEmail(value)) return 'INVALID FORMAT';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildTechnicalField(
                      controller: _passwordController,
                      label: "ACCESS KEY",
                      hint: "Min. 6 characters",
                      icon: Icons.vpn_key_outlined,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'REQUIRED';
                        if (value.length < 6) return 'INSUFFICIENT LENGTH';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Sign Up Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _authController.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22D3EE),
                            foregroundColor: const Color(0xFF08080A),
                            disabledBackgroundColor: const Color(0xFF22D3EE).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4), // Sharp technical corners
                            ),
                            elevation: 0,
                          ),
                          child: _authController.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF08080A),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "INITIALIZE PROTOCOL",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Navigation
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: RichText(
                          text: TextSpan(
                            text: "ALREADY SYNCHRONIZED? ",
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
                    
                    const SizedBox(height: 40),
                    
                    // Security Footer
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.2), size: 16),
                          const SizedBox(height: 8),
                          Text(
                            "QUANTUM-RESISTANT ENCRYPTION ENABLED",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFF22D3EE),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
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
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class RegistrationMeshPainter extends CustomPainter {
  final double rotation;

  RegistrationMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.03)
      ..strokeWidth = 0.5;

    final center = Offset(size.width, 0); // Originating from top right
    const nodes = 12;
    final radius = size.width * 0.8;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (rotation * 0.5 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      // Draw lines to center
      canvas.drawLine(Offset(x, y), center, paint);
      
      // Draw a secondary web
      final nextAngle = ((i + 1) * 2 * math.pi / nodes) + (rotation * 0.5 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RegistrationMeshPainter oldDelegate) => true;
}