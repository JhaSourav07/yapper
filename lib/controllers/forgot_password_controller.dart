import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yapper/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _emailSent = false.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get emailSent => _emailSent.value;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  /// Initiates the key recovery protocol
  Future<void> sendPasswordResetEmail() async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      _isLoading.value = true;
      _error.value = '';
      final String email = emailController.text.trim();

      // 1. Verify if the node identity exists in the Firestore mesh
      // Firebase Auth doesn't reveal if an email is missing, so we check the DB
      final QuerySnapshot nodeCheck = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .timeout(const Duration(seconds: 10));

      if (nodeCheck.docs.isEmpty) {
        _error.value = "IDENTITY NOT FOUND: NODE IS NOT REGISTERED ON THIS MESH";
        return;
      }

      // 2. Execute transmission via AuthService
      await _authService.sendPasswordResetEmail(email: email);
      
      _emailSent.value = true;
      
      Get.snackbar(
        'TRANSMISSION SUCCESS',
        'Recovery link dispatched to $email',
        backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
        colorText: const Color(0xFF22D3EE),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      
    } catch (e) {
      _error.value = "PROTOCOL ERROR: ${e.toString().toUpperCase()}";
      Get.snackbar(
        'TRANSMISSION FAILED',
        'Unable to initialize recovery: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Returns user to the login core
  void goBackTologin() {
    Get.back();
  }

  /// Retransmits the recovery link
  void resendEmail() {
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

  /// Validates node identity format
  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'IDENTITY STRING REQUIRED';
    }
    if (!GetUtils.isEmail(value!)) {
      return 'INVALID IDENTITY FORMAT';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}