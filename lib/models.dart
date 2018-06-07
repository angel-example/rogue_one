/// Our user class. Named affectionately.
class ForceSensitive {
  String id;
  String username, password;
  bool isSith;

  ForceSensitive({this.username, this.password, this.isSith});

  ForceSensitive.fromMap(Map map)
      : id = map['id'],
        username = map['username'],
        password = map['password'],
        isSith = map['is_sith'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'is_sith': isSith
    };
  }
}

class Lightsaber {
  String id;
  String userId;
  String color;

  Lightsaber({this.id, this.userId, this.color});

  Lightsaber.fromMap(Map map)
  : id = map['id'],
  userId = map['user_id'],
  color = map['color'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'color': color,
    };
  }

}
