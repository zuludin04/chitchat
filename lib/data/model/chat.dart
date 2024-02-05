import 'package:image_picker/image_picker.dart';

class Chat {
  final String id;
  final String senderId;
  final String groupId;
  final String senderName;
  final String senderImage;
  final String message;
  final String messageType;
  final int messageSent;

  XFile? mediaFile;

  Chat({
    required this.id,
    required this.senderId,
    required this.groupId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.messageType,
    required this.messageSent,
    this.mediaFile,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      senderId: map['senderId'],
      groupId: map['groupId'],
      senderName: map['senderName'],
      senderImage: map['senderImage'],
      message: map['message'],
      messageType: map['messageType'],
      messageSent: map['messageSent'],
    );
  }

  Map<String, dynamic> toMap({String? id, String? message}) {
    var map = <String, dynamic>{};
    map['id'] = id ?? this.id;
    map['senderId'] = senderId;
    map['groupId'] = groupId;
    map['senderName'] = senderName;
    map['senderImage'] = senderImage;
    map['message'] = message ?? this.message;
    map['messageType'] = messageType;
    map['messageSent'] = messageSent;
    return map;
  }
}
