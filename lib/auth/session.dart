class Session {
  static String? userKey;
  static String? username;
  static String? role;

  static void setUser({
    required String key,
    required String usernameValue,
    required String roleValue,
  }) {
    userKey = key;
    username = usernameValue;
    role = roleValue;
  }

  static void clear() {
    userKey = null;
    username = null;
    role = null;
  }

  static bool get isLoggedIn => userKey != null;
}