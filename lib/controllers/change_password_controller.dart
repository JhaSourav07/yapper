import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';

class ChangePasswordController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _obscureCurrentPassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxBool _obscureNewPassword = true.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get obscureCurrentPassword => _obscureCurrentPassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;
  bool get obscureNewPassword => _obscureNewPassword.value;

  @override
  void onClose() {
    currentPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword.value = !_obscureCurrentPassword.value;
  }
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }
  void toggleNewPasswordVisibility() {
    _obscureNewPassword.value = !_obscureNewPassword.value;
  }

  /// Executes the access key rotation protocol with mandatory re-authentication
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;
      _error.value = '';
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'IDENTITY_LOST: NO ACTIVE SESSION FOUND',
        );
      }

      // 1. RE-AUTHENTICATION PROTOCOL
      // Sensitive operations like password changes require a fresh credential.
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text.trim(),
      );

      // Verify the node's current access key with the core
      await user.reauthenticateWithCredential(credential);

      // 2. UPDATE ACCESS KEY
      await user.updatePassword(newPasswordController.text.trim());

      // 3. SUCCESS FEEDBACK
      Get.snackbar(
        'PROTOCOL SUCCESS',
        'Access key rotated successfully. Security integrity maintained.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
        colorText: const Color(0xFF22D3EE),
        duration: const Duration(seconds: 3),
      );

      // 4. CORE CLEANUP
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Return to Profile Core
      Get.back();

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'VALIDATION FAILED: CURRENT KEY IS INCORRECT';
          break;
        case 'weak-password':
          errorMessage = 'PROTOCOL ERROR: NEW KEY IS INSUFFICIENTLY SECURE';
          break;
        case 'requires-recent-login':
          errorMessage = 'SESSION EXPIRED: PLEASE RE-AUTHENTICATE TO CONTINUE';
          break;
        case 'too-many-requests':
          errorMessage = 'SYSTEM OVERLOAD: SECURITY LOCKOUT IN EFFECT';
          break;
        default:
          errorMessage = 'PROTOCOL FAILURE: ${e.message?.toUpperCase() ?? e.code.toUpperCase()}';
      }
      
      _error.value = errorMessage;
      
      Get.snackbar(
        'PROTOCOL REJECTED',
        errorMessage,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      _error.value = 'SYSTEM ERROR: UNABLE TO COMMUNICATE WITH MESH CORE';
      Get.snackbar(
        'SYSTEM FAILURE',
        'An unexpected error occurred during encryption update.',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // --- VALIDATORS ---

  String? validateCurrentPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CURRENT KEY REQUIRED';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NEW KEY REQUIRED';
    }
    if (value.trim().length < 6) {
      return 'MINIMUM 6 CHARACTERS REQUIRED';
    }
    if (value.trim() == currentPasswordController.text.trim()) {
      return 'NEW KEY MUST DIFFER FROM CURRENT KEY';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CONFIRMATION REQUIRED';
    }
    if (value.trim() != newPasswordController.text.trim()) {
      return 'KEYS DO NOT MATCH';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}