import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yapper/models/user_model.dart';
import 'package:yapper/routes/app_routes.dart';
import 'package:yapper/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isAuthenticated = false.obs;
  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isAuthenticated => _isAuthenticated.value;
  String get error => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    ever<User?>(_user, _handleAuthStateChange);
    
  }

  void _handleAuthStateChange(User? firebaseUser) async {
    if(user == null){
      if (Get.currentRoute != AppRoutes.login){
        Get.offAllNamed(AppRoutes.login);
      }
    }
    else {
      if (Get.currentRoute != AppRoutes.main){
        Get.offAllNamed(AppRoutes.main);
      }
    }
    if(!_isInitialized.value){
      _isInitialized.value = true;
    }
  }

  void checkInitialAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
    _isInitialized.value = true;
  }


  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      UserModel? userModel = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if(userModel != null){
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Login Error', _errorMessage.value);
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      UserModel? userModel = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      if(userModel != null){
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Failed to Create Account', _errorMessage.value);
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Logout Error', _errorMessage.value);
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Future<void> sendPasswordResetEmail(String email) async {
  //   try {
  //     _isLoading.value = true;
  //     _errorMessage.value = '';
  //     await _authService.sendPasswordResetEmail(email: email);
  //     Get.snackbar('Password Reset', 'A password reset email has been sent to $email');
  //   } catch (e) {
  //     _errorMessage.value = e.toString();
  //     Get.snackbar('Password Reset Error', _errorMessage.value);
  //     print(e);
  //   } finally {
  //     _isLoading.value = false;
  //   }
  // }

  // Future<void> updateUserOnlineStatus(bool isOnline) async {
  //   try {
  //     if (user != null) {
  //       await _authService.updateUserOnlineStatus(user!.uid, isOnline);
  //     }
  //   } catch (e) {
  //     print("Failed to update online status: $e");
  //   }
  // } 

  // Future<void> refreshUserModel() async {
  //   try {
  //     if (user != null) {
  //       UserModel? updatedUserModel = await _authService.getUserModel(user!.uid);
  //       if (updatedUserModel != null) {
  //         _userModel.value = updatedUserModel;
  //       }
  //     }
  //   } catch (e) {
  //     print("Failed to refresh user model: $e");
  //   }
  // }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      if (user != null) {
        await _authService.deleteAccount();
        _userModel.value = null;
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Account Deletion Error', _errorMessage.value);
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

}
