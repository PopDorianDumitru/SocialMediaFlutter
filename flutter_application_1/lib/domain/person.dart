class Person extends Object {
  late String _name, _username, _email, _passwordHash, _id, _fcmToken;
  Person(String id, String name, String username, String email,
      String passwordHash) {
    _email = email;
    _id = id;
    _name = name;
    _username = username;
    _passwordHash = passwordHash;
  }
  void setName(String value) {
    _name = value;
  }

  void setUserName(String value) {
    _username = value;
  }

  void setEmail(String value) {
    _email = value;
  }

  void setPasswordHash(String value) {
    _passwordHash = value;
  }

  void setFCMToken(String value) {
    _fcmToken = value;
  }

  String getName() {
    return _name;
  }

  String getFcmToken() {
    return _fcmToken;
  }

  String getUserName() {
    return _username;
  }

  String getEmail() {
    return _email;
  }

  String getPasswordHash() {
    return _passwordHash;
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': _id,
      'name': _name,
      'email': _email,
      'passwordHash': _passwordHash,
      'username': _username,
      'fcmToken': _fcmToken
    };
  }

  void erase() {
    _name = "";
    _email = "";
    _fcmToken = "";
    _id = "";
    _passwordHash = "";
    _username = "";
  }

  Person.fromMap(Map<String, dynamic> map)
      : _name = map['name'],
        _username = map['username'],
        _email = map['email'],
        _id = map['_id'],
        _fcmToken = "",
        _passwordHash = map['passwordHash'];
}
