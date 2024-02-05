class Profile {
  final String uid;
  final String name;
  final String image;

  Profile({required this.uid, required this.name, required this.image});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(uid: map['uid'], name: map['name'], image: map['image']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['uid'] = uid;
    map['name'] = name;
    map['image'] = image;
    return map;
  }
}
