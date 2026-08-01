import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/models/message_model.dart';
import 'package:yapper/models/user_model.dart';
import 'package:yapper/services/firestore_service.dart';
import 'package:yapper/services/rtdb_service.dart';

class ChatController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final RtdbService _rtdbService = RtdbService();
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isTargetTyping = false.obs;

  late String chatId;
  late UserModel targetUser;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments ?? {};
    chatId = args['chatId'] ?? '';
    targetUser = args['targetUser'];

    _bindMessagesStream();
    _bindTypingStream();
    _markAsRead();
    
    messageController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _onStopTyping();
    messageController.removeListener(_onTextChanged);
    messageController.dispose();
    scrollController.dispose();
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    super.onClose();
  }

  void _onTextChanged() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null || chatId.isEmpty) return;

    if (messageController.text.isNotEmpty) {
      _rtdbService.setTypingStatus(chatId, currentUserId, true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _onStopTyping();
      });
    } else {
      _onStopTyping();
    }
  }

  void _onStopTyping() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null && chatId.isNotEmpty) {
      _rtdbService.setTypingStatus(chatId, currentUserId, false);
    }
  }

  void _bindTypingStream() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null || chatId.isEmpty) return;

    _typingSubscription = _rtdbService
        .getTypingStream(chatId, currentUserId)
        .listen((typing) {
      isTargetTyping.value = typing;
    });
  }

  void _bindMessagesStream() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null || targetUser.id.isEmpty) {
      isLoading.value = false;
      return;
    }

    _messagesSubscription = _firestoreService
        .getMessagesStream(currentUserId, targetUser.id)
        .listen((msgs) {
      messages.assignAll(msgs);
      isLoading.value = false;

      // Scroll to bottom when new messages arrive
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }, onError: (e) {
      print("Error loading messages: $e");
      isLoading.value = false;
    });
  }

  void _markAsRead() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null && chatId.isNotEmpty) {
      _firestoreService.restoreUnreadCount(chatId, currentUserId);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    messageController.clear();

    final message = MessageModel(
      id: '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      receiverId: targetUser.id,
      content: text,
      timestamp: DateTime.now(),
    );

    try {
      await _firestoreService.sendMessage(message);
    } catch (e) {
      Get.snackbar("TRANSMISSION ERROR", "Failed to send message: $e");
    }
  }
}
