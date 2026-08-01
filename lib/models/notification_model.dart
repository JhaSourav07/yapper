enum NotificationType {
  friendRequest,
  friendRequestAccepted,
  friendRequestDeclined,
  newMessage,
  friendRemoved,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  static NotificationModel fromMap(Map<String, dynamic> map) {
    NotificationType parsedType = NotificationType.newMessage;
    final rawType = map['type'];
    if (rawType is int && rawType >= 0 && rawType < NotificationType.values.length) {
      parsedType = NotificationType.values[rawType];
    } else if (rawType is String) {
      parsedType = NotificationType.values.firstWhere(
        (e) => e.name == rawType,
        orElse: () => NotificationType.newMessage,
      );
    }

    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: parsedType,
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'])
          : {},
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}