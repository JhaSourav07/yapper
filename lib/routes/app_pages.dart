import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/utils.dart';
import 'package:yapper/routes/app_routes.dart';
import 'package:yapper/views/splash_screen.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      
    ),
    // GetPage(
    //   name: AppRoutes.home,
    //   page: () => HomeScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(HomeController());
    //   }),
    // ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      
    ),
    // GetPage(
    //   name: AppRoutes.register,
    //   page: () => RegisterScreen(),
      
    // ),
    // GetPage(
    //   name: AppRoutes.forgotPassword,
    //   page: () => ForgotPasswordScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(ForgotPasswordController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.changePassword,
    //   page: () => ChangePasswordScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(ChangePasswordController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.profile,
    //   page: () => ProfileScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(ProfileController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.chat,
    //   page: () => ChatScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(ChatController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.usersList,
    //   page: () => UsersListScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(UsersListController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.friends,
    //   page: () => FriendsScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(FriendsController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.friendRequests,
    //   page: () => FriendRequestsScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(FriendRequestsController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.notifications,
    //   page: () => NotificationsScreen(),
    //   binding: BindingBuilder(() {
    //     Get.put(NotificationsController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.main,
    //   page: () => MainScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(MainController());
    //   }),
    // ),
    // GetPage(
    //   name: AppRoutes.profile,
    //   page: () => ProfileScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(ProfileController());
    //   }),
    // ),
  ];
}
