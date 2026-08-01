import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/models/friend_request_model.dart';
import 'package:yapper/models/user_model.dart';
import 'package:yapper/routes/app_routes.dart';
import 'package:yapper/services/firestore_service.dart';

enum UserRelationStatus {
  none,
  pendingSent,
  pendingReceived, // Optional: if you want to show "Accept" here too
  friend,
  blocked,
  self,
}

class UsersListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  // Data State
  final RxList<UserModel> _allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  
  // Relationship State Maps
  final RxMap<String, String> _sentRequestIds = <String, String>{}.obs; // ReceiverId -> RequestId
  final RxMap<String, String> _receivedRequestIds = <String, String>{}.obs; // SenderId -> RequestId
  final RxList<String> _friendIds = <String>[].obs;
  
  // UI State
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = true.obs;

  // Cleanup
  final List<StreamSubscription> _subscriptions = [];
  Worker? _filterWorker;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  @override
  void onClose() {
    searchController.dispose();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _filterWorker?.dispose();
    super.onClose();
  }

  void _bindStreams() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) {
      isLoading.value = false;
      return;
    }

    // 1. Listen to All Users
    final usersStream = _firestoreService.getAllUsersStream().handleError((e) {
      print("Error fetching users: $e");
      isLoading.value = false;
    });
    
    _allUsers.bindStream(usersStream);
    
    // 2. Listen to Sent Requests
    final sentReqSub = _firestoreService.getSentFriendRequestsStream(currentUserId).listen(
      (requests) {
        final newMap = <String, String>{};
        for (var req in requests) {
          if (req.status == FriendRequestStatus.pending) {
            newMap[req.receiverId] = req.id;
          }
        }
        _sentRequestIds.assignAll(newMap);
      },
      onError: (e) => print("Error in sent requests stream: $e"),
    );
    _subscriptions.add(sentReqSub);

    // 3. Listen to Received Requests
    final receivedReqSub = _firestoreService.getFriendRequestsStream(currentUserId).listen(
      (requests) {
        final newMap = <String, String>{};
        for (var req in requests) {
          if (req.status == FriendRequestStatus.pending) {
            newMap[req.senderId] = req.id;
          }
        }
        _receivedRequestIds.assignAll(newMap);
      },
      onError: (e) => print("Error in received requests stream: $e"),
    );
    _subscriptions.add(receivedReqSub);

    // 4. Listen to Friends
    final friendSub = _firestoreService.getFriendStream(currentUserId).listen(
      (friendships) {
        final newFriendIds = <String>[];
        for (var f in friendships) {
          String otherId = f.user1Id == currentUserId ? f.user2Id : f.user1Id;
          newFriendIds.add(otherId);
        }
        _friendIds.assignAll(newFriendIds);
      },
      onError: (e) => print("Error in friends stream: $e"),
    );
    _subscriptions.add(friendSub);

    _filterWorker = ever(_allUsers, (_) => _filterUsers());
    searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    if (_allUsers.isEmpty && isLoading.value) {
       isLoading.value = false;
    }

    final query = searchController.text.toLowerCase();
    final currentUserId = _authController.user?.uid;

    List<UserModel> temp = _allUsers.where((user) {
      if (user.id == currentUserId) return false;
      final nameMatch = user.displayName.toLowerCase().contains(query);
      final emailMatch = user.email.toLowerCase().contains(query);
      return nameMatch || emailMatch;
    }).toList();

    filteredUsers.assignAll(temp);
    if (isLoading.value) isLoading.value = false;
  }

  // --- Logic Helpers ---

  UserRelationStatus getRelationStatus(String targetUserId) {
    final currentUserId = _authController.user?.uid;
    if (targetUserId == currentUserId) {
      return UserRelationStatus.self;
    }
    if (_friendIds.contains(targetUserId)) {
      return UserRelationStatus.friend;
    }
    if (_sentRequestIds.containsKey(targetUserId)) {
      return UserRelationStatus.pendingSent;
    }
    if (_receivedRequestIds.containsKey(targetUserId)) {
      return UserRelationStatus.pendingReceived;
    }
    return UserRelationStatus.none;
  }

  // --- Actions ---

  Future<void> acceptFriendRequest(String targetUserId) async {
    final requestId = _receivedRequestIds[targetUserId];
    if (requestId == null) return;

    try {
      await _firestoreService.respondToFriendRequest(
        requestId,
        FriendRequestStatus.accepted,
      );
      Get.snackbar(
        "LINK ESTABLISHED",
        "Friend request accepted!",
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
        colorText: const Color(0xFF10B981),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("ERROR", "Failed to accept request: $e");
    }
  }

  Future<void> declineFriendRequest(String targetUserId) async {
    final requestId = _receivedRequestIds[targetUserId];
    if (requestId == null) return;

    try {
      await _firestoreService.respondToFriendRequest(
        requestId,
        FriendRequestStatus.declined,
      );
    } catch (e) {
      Get.snackbar("ERROR", "Failed to decline request: $e");
    }
  }

  // --- Actions ---

  Future<void> sendFriendRequest(UserModel targetUser) async {
    final currentUser = _authController.userModel;
    if (currentUser == null) return;

    try {
      final String requestId = '${currentUser.id}_${targetUser.id}';
      
      final request = FriendRequestModel(
        id: requestId,
        senderId: currentUser.id,
        receiverId: targetUser.id,
        status: FriendRequestStatus.pending,
        sentAt: DateTime.now(),
        message: "Let's connect on the mesh.",
      );

      await _firestoreService.sendFriendRequest(request);
      
      // Optimistic update handled by stream, but we can add snackbar
      Get.snackbar(
        "SIGNAL TRANSMITTED", 
        "Request sent to ${targetUser.displayName}",
        backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
        colorText: const Color(0xFF22D3EE),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar("ERROR", "Transmission failed: $e");
    }
  }

  Future<void> cancelFriendRequest(String targetUserId) async {
    final requestId = _sentRequestIds[targetUserId];
    if (requestId == null) return;

    try {
      await _firestoreService.cancelFriendRequest(requestId);
    } catch (e) {
      Get.snackbar("ERROR", "Failed to abort signal: $e");
    }
  }

  Future<void> blockUser(String targetUserId) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    try {
      await _firestoreService.blockUser(currentUserId, targetUserId);
      Get.snackbar(
        "NODE BLOCKED", 
        "Communication protocols severed.",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("ERROR", "Block failed: $e");
    }
  }

  Future<void> startChat(UserModel targetUser) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    try {
      // 1. Get Chat ID
      String chatId = await _firestoreService.createOrGetChat(currentUserId, targetUser.id);
      
      // 2. Navigate to Chat Screen
      Get.toNamed(
        AppRoutes.chat, 
        arguments: {
          'chatId': chatId,
          'targetUser': targetUser, // passing the model often helps setup the header faster
        }
      );
    } catch (e) {
      Get.snackbar("ERROR", "Connection failed: $e");
    }
  }
}