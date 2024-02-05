class Group {
  final String id;
  final String name;
  final String lastMessage;
  final String lastSender;
  final int lastSent;

  Group({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastSender,
    required this.lastSent,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      lastMessage: map['lastMessage'],
      lastSender: map['lastSender'],
      lastSent: map['lastSent'],
    );
  }

  Map<String, dynamic> toMap({String? groupId}) {
    var map = <String, dynamic>{};
    map['id'] = groupId ?? id;
    map['name'] = name;
    map['lastMessage'] = lastMessage;
    map['lastSender'] = lastSender;
    map['lastSent'] = lastSent;
    return map;
  }
}
