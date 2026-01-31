import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/services/firestore_service.dart';

import '../models/user_model.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isEditing = false.obs;
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;
  bool get isEditing => _isEditing.value;
  String get error => _error.value;
  UserModel? get currentUser => _userModel.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    displayNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _userModel.bindStream(_firestoreService.getUserStream(currentUserId));

      ever(_userModel, (UserModel? user) {
        if (user != null) {
          // SAFETY CHECK: Only update text if it's actually different.
          // This prevents unnecessary rebuild cycles.
          if (displayNameController.text != user.name) {
            displayNameController.text = user.name;
          }
          if (emailController.text != user.email) {
            emailController.text = user.email;
          }
        }
      });
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;
    if (!_isEditing.value) {
      final user = _userModel.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        emailController.text = user.email;
      }
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final user = _userModel.value;
      if (user == null) throw Exception("No user data available");

      final updatedUser = user.copyWith(
        displayName: displayNameController.text.trim(),
      );

      await _firestoreService.updateUser(updatedUser);
      _isEditing.value = false;

      Get.snackbar(
        'UPDATE SUCCESS',
        'Profile updated successfully',
        backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
        colorText: const Color(0xFF22C55E),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = e.toString();
      print(e.toString());
      Get.snackbar(
        'UPDATE FAILED',
        _error.value,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
        colorText: const Color(0xFFEF4444),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authController.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final result = await Get.defaultDialog(
        title: 'CONFIRM ACCOUNT DELETION',
        middleText:
            'ARE YOU SURE YOU WANT TO DELETE YOUR ACCOUNT? THIS ACTION CANNOT BE UNDONE.',
        textCancel: 'CANCEL',
        textConfirm: 'DELETE',
        confirmTextColor: CupertinoColors.white,
        onConfirm: () {
          Get.back(result: true);
        },
        onCancel: () {
          Get.back(result: false);
        },
      );
      if (result == true) {
        _isLoading.value = true;
        await _authController.deleteAccount();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  String getJoinedData() {
    final user = _userModel.value;
    if (user == null) return '';
    final date = user.createdAt;

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "Joined ${months[date.month - 1]} ${date.year}";
  }

  void clearError() {
    _error.value = '';
  } 
}
