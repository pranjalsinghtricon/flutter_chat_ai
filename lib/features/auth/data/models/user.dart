class User {
  final String id;
  final String username;
  final String? fullName;
  final String? idToken;
  final String? accessToken;
  final String? refreshToken;

  const User({
    required this.id,
    required this.username,
    this.fullName,
    this.idToken,
    this.accessToken,
    this.refreshToken,
  });

  User copyWith({String? fullName}) {
    return User(
      id: id,
      username: username,
      fullName: fullName ?? this.fullName,
      idToken: idToken,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
