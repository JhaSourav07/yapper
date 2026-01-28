import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;

/// A refined splash screen for Yapper featuring a dynamic "Secure Mesh" animation.
/// Uses a combination of pulsing particles and a glassmorphic central core.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  
  String _loadingText = "SECURE HANDSHAKE";
  final List<String> _states = [
    "INITIALIZING KERNEL",
    "ESTABLISHING MESH",
    "ENCRYPTING NODES",
    "SYNCHRONIZING",
    "READY"
  ];
  int _stateIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Pulse Controller for the central glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 2. Rotation Controller for the outer rings
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Technical text sequence
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        if (_stateIndex < _states.length - 1) {
          setState(() {
            _stateIndex++;
            _loadingText = _states[_stateIndex];
          });
        } else {
          timer.cancel();
          _handleNavigation();
        }
      }
    });
  }

  Future<void> _handleNavigation() async {
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep obsidian
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background: Subtle Animated Mesh Particles
          CustomPaint(
            painter: MeshPainter(
              pulse: _pulseController.value,
              rotation: _rotationController.value,
            ),
            size: Size.infinite,
          ),

          // Central Visual
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: _buildSecureCore(),
              ),
              const SizedBox(height: 60),
              
              // Typography
              const Text(
                "YAPPER",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 18,
                ),
              ),
              const SizedBox(height: 10),
              
              // Status Bar
              _buildStatusBar(),
            ],
          ),

          // Bottom Security Branding
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildSecureCore() {
    return RotationTransition(
      turns: _rotationController,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.5),
              Colors.transparent,
              const Color(0xFFA855F7).withOpacity(0.5),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF08080A),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Color(0xFF22D3EE),
            size: 44,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Column(
      children: [
        Text(
          _loadingText,
          style: TextStyle(
            color: const Color(0xFF22D3EE).withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 120,
          height: 1,
          color: Colors.white.withOpacity(0.05),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 120 * ((_stateIndex + 1) / _states.length),
              height: 1,
              color: const Color(0xFF22D3EE),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 60,
      child: Column(
        children: [
          Icon(Icons.fingerprint_rounded, color: Colors.white.withOpacity(0.2), size: 28),
          const SizedBox(height: 12),
          Text(
            "END-TO-END ENCRYPTED SYSTEM",
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for the background mesh effect
class MeshPainter extends CustomPainter {
  final double pulse;
  final double rotation;

  MeshPainter({required this.pulse, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.05)
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height / 2);
    const nodes = 8;
    final radius = 150.0 + (pulse * 20);

    for (var i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (rotation * 2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 2, paint);
      
      // Draw lines to next node
      final nextAngle = ((i + 1) * 2 * math.pi / nodes) + (rotation * 2 * math.pi);
      final nx = center.dx + radius * math.cos(nextAngle);
      final ny = center.dy + radius * math.sin(nextAngle);
      
      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);
      
      // Draw lines to center
      canvas.drawLine(Offset(x, y), center, paint..color = paint.color.withOpacity(0.02));
    }
  }

  @override
  bool shouldRepaint(covariant MeshPainter oldDelegate) => true;
}