enum FriendRequestStatus {
  pending,
  accepted,
  declined,
}

class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final String? message;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.sentAt,
    this.respondedAt,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.index,
      'sentAt': sentAt.millisecondsSinceEpoch,
      'respondedAt': respondedAt?.millisecondsSinceEpoch,
      'message': message,
    };
  }
  static FriendRequestModel fromMap(Map<String, dynamic> map) {
    return FriendRequestModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      sentAt: DateTime.fromMillisecondsSinceEpoch(map['sentAt'] ?? 0),
      respondedAt: map['respondedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'])
          : null,
      message: map['message'],
    );
  }

  FriendRequestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    FriendRequestStatus? status,
    DateTime? sentAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }

}