import 'dart:async';
import 'package:get/get.dart';
import 'package:yapper/controllers/auth_controller.dart';
import 'package:yapper/models/friend_request_model.dart';
import 'package:yapper/models/friendship_model.dart';
import 'package:yapper/models/user_model.dart';
import 'package:yapper/routes/app_routes.dart';
import 'package:yapper/services/firestore_service.dart';

/// Helper class to bundle request data with sender user data
class RequestWithUser {
  final FriendRequestModel request;
  final UserModel user;
  RequestWithUser(this.request, this.user);
}

/// Helper class to bundle friendship data with friend user data
class FriendWithUser {
  final FriendshipModel friendship;
  final UserModel user;
  FriendWithUser(this.friendship, this.user);
}

class FriendsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  // Data State
  final RxList<RequestWithUser> incomingRequests = <RequestWithUser>[].obs;
  final RxList<FriendWithUser> friends = <FriendWithUser>[].obs;

  // Loading State
  final RxBool isLoadingRequests = true.obs;
  final RxBool isLoadingFriends = true.obs;

  List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  @override
  void onClose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }

  void _bindStreams() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    // 1. Listen to Incoming Friend Requests
    final reqSub = _firestoreService.getFriendRequestsStream(currentUserId).listen(
      (requests) async {
        isLoadingRequests.value = true;
        final List<RequestWithUser> loaded = [];
        
        for (var req in requests) {
          // Fetch the sender's user details
          final user = await _firestoreService.getUser(req.senderId);
          if (user != null) {
            loaded.add(RequestWithUser(req, user));
          }
        }
        
        incomingRequests.assignAll(loaded);
        isLoadingRequests.value = false;
      },
      onError: (e) => print("Error loading requests: $e"),
    );
    _subscriptions.add(reqSub);

    // 2. Listen to Friends List
    final friendSub = _firestoreService.getFriendStream(currentUserId).listen(
      (friendships) async {
        isLoadingFriends.value = true;
        final List<FriendWithUser> loaded = [];

        for (var f in friendships) {
          // Determine the OTHER user's ID
          final otherId = f.user1Id == currentUserId ? f.user2Id : f.user1Id;
          final user = await _firestoreService.getUser(otherId);
          
          if (user != null) {
            loaded.add(FriendWithUser(f, user));
          }
        }

        friends.assignAll(loaded);
        isLoadingFriends.value = false;
      },
      onError: (e) => print("Error loading friends: $e"),
    );
    _subscriptions.add(friendSub);
  }

  // --- Actions ---

  Future<void> acceptRequest(String requestId) async {
    try {
      await _firestoreService.respondToFriendRequest(
        requestId,
        FriendRequestStatus.accepted,
      );
      // UI updates automatically via stream
    } catch (e) {
      Get.snackbar("ERROR", "Failed to establish link: $e");
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await _firestoreService.respondToFriendRequest(
        requestId,
        FriendRequestStatus.declined,
      );
    } catch (e) {
      Get.snackbar("ERROR", "Failed to reject signal: $e");
    }
  }

  Future<void> startChat(UserModel targetUser) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    try {
      String chatId = await _firestoreService.createOrGetChat(currentUserId, targetUser.id);
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'chatId': chatId,
          'targetUser': targetUser,
        },
      );
    } catch (e) {
      Get.snackbar("ERROR", "Connection failed: $e");
    }
  }

  Future<void> removeFriend(String friendId) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    try {
      await _firestoreService.removeFriendship(currentUserId, friendId);
    } catch (e) {
      Get.snackbar("ERROR", "Failed to terminate link: $e");
    }
  }
}