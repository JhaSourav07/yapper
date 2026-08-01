import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/controllers/users_list_controller.dart';
import 'package:yapper/routes/app_routes.dart';
import 'package:yapper/views/splash_screen.dart';
import '../controllers/change_password_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/main_screen.dart';
import '../views/profile/change_password_screen.dart';
import '../views/profile/profile_screen.dart';

import 'package:yapper/controllers/chat_controller.dart';
import 'package:yapper/controllers/friends_controller.dart';
import 'package:yapper/views/chat_screen.dart';
import 'package:yapper/views/friends_screen.dart';

import 'package:yapper/controllers/notifications_controller.dart';
import 'package:yapper/views/notifications_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordScreen(),
      binding: BindingsBuilder(() {
        Get.put(ChangePasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: BindingsBuilder(() {
        Get.put(ChatController());
      }),
    ),
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendsScreen(),
      binding: BindingsBuilder(() {
        Get.put(FriendsController());
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        Get.put(NotificationsController());
      }),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController(), permanent: true);
        }
      }),
    ),
  ];
}
