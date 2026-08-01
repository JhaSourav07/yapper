import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RtdbService {
  static const String databaseUrl =
      'https://yapper-chat-application-default-rtdb.asia-southeast1.firebasedatabase.app';

  late final FirebaseDatabase _rtdb;

  RtdbService() {
    try {
      _rtdb = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );
    } catch (e) {
      _rtdb = FirebaseDatabase.instance;
    }
  }

  /// Updates typing status for a user in a specific chat
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    if (chatId.isEmpty || userId.isEmpty) return;
    try {
      final ref = _rtdb.ref('typing/$chatId/$userId');
      if (isTyping) {
        await ref.set(true);
        if (!kIsWeb) {
          ref.onDisconnect().set(false);
        }
      } else {
        await ref.set(false);
      }
    } catch (_) {
      // Platform channel will connect cleanly after full app restart
    }
  }

  /// Stream to listen if any other user in the chat is currently typing
  Stream<bool> getTypingStream(String chatId, String currentUserId) {
    if (chatId.isEmpty) return Stream.value(false);

    try {
      final ref = _rtdb.ref('typing/$chatId');
      return ref.onValue.map((event) {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return false;

        final Map<dynamic, dynamic> map = data;
        for (var entry in map.entries) {
          final key = entry.key.toString();
          final value = entry.value;
          if (key != currentUserId && (value == true || value == 'true')) {
            return true;
          }
        }
        return false;
      }).handleError((_) => false);
    } catch (_) {
      return Stream.value(false);
    }
  }
}
