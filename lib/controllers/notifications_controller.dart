import 'dart:async';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/models/notification_model.dart';
import 'package:yapper/services/firestore_service.dart';

class NotificationsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _subscription;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _bindNotificationsStream();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _bindNotificationsStream() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) {
      isLoading.value = false;
      return;
    }

    _subscription = _firestoreService
        .getNotificationsStream(currentUserId)
        .listen((list) {
      notifications.assignAll(list);
      isLoading.value = false;
    }, onError: (e) {
      print("Error loading notifications: $e");
      isLoading.value = false;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
    } catch (e) {
      print("Error marking notification read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    try {
      await _firestoreService.markAllNotificationsAsRead(currentUserId);
    } catch (e) {
      print("Error marking all read: $e");
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestoreService.deleteNotification(notificationId);
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }
}
