import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  
  late AnimationController _rotationController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// Handles the authentication protocol asynchronously
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Execute sign-in and wait for the result
      await _authController.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // Explicitly check for successful authentication to trigger navigation
      // This prevents the UI from getting stuck if the controller doesn't 
      // handle global navigation internally.
      if (_authController.isAuthenticated) {
        Get.offAllNamed(AppRoutes.profile);
      }
      else {
        // Optionally, show an error message if authentication fails
        // Get.snackbar(
        //   "AUTHENTICATION FAILED",
        //   _authController.error.isNotEmpty ? _authController.error : "PLEASE CHECK CREDENTIALS",
        //   backgroundColor: AppTheme.bgDark,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep obsidian
      body: Stack(
        children: [
          // Background Mesh Effect (Originating from bottom-left for visual variety)
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: LoginMeshPainter(
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
                    const SizedBox(height: 60),
                    
                    // Technical Header Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF22D3EE).withOpacity(0.2),
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.1),
                              const Color(0xFFA855F7).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          color: Color(0xFF22D3EE),
                          size: 48,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Typography
                    Text(
                      "AUTHENTICATION REQUIRED",
                      style: TextStyle(
                        color: const Color(0xFF22D3EE).withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "ACCESS CORE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Provide your credentials to establish a secure link.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Input Fields
                    _buildTechnicalField(
                      controller: _emailController,
                      label: "NODE IDENTITY (EMAIL)",
                      hint: "node@mesh.network",
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'REQUIRED';
                        if (!GetUtils.isEmail(value)) return 'INVALID FORMAT';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildTechnicalField(
                      controller: _passwordController,
                      label: "ACCESS KEY (PASSWORD)",
                      hint: "••••••••",
                      icon: Icons.vpn_key_outlined,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) => (value == null || value.isEmpty) ? 'REQUIRED' : null,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        child: Text(
                          "RECOVER KEY",
                          style: TextStyle(
                            color: const Color(0xFF22D3EE).withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Login Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _authController.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22D3EE),
                            foregroundColor: const Color(0xFF08080A),
                            disabledBackgroundColor: const Color(0xFF22D3EE).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
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
                                  "ESTABLISH LINK",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Navigation to Register
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: RichText(
                          text: TextSpan(
                            text: "NEW NODE? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            children: const [
                              TextSpan(
                                text: "INITIALIZE IDENTITY",
                                style: TextStyle(
                                  color: Color(0xFF22D3EE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Footer Security Info
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 1,
                            color: const Color(0xFF22D3EE).withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "SYSTEM STATUS: SECURE",
                            style: TextStyle(
                              color: const Color(0xFF22D3EE).withOpacity(0.3),
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
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFF22D3EE),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
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

class LoginMeshPainter extends CustomPainter {
  final double rotation;

  LoginMeshPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.04) // Purple tint for login
      ..strokeWidth = 0.5;

    final center = Offset(0, size.height); // Bottom-left origin
    const nodes = 10;
    final radius = size.width * 0.7;

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) - (rotation * 0.3 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(Offset(x, y), center, paint);
      
      final nextAngle = ((i + 1) * 2 * math.pi / nodes) - (rotation * 0.3 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LoginMeshPainter oldDelegate) => true;
}