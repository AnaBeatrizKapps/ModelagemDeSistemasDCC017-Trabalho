class FirestorePath {
  static String todo(String uid, String todoId) => 'users/$uid/todos/$todoId';
  static String todos(String uid) => 'users/$uid/todos';
  static String houses(String uid) => 'houses';
  static String history(String uid) => 'houses/${uid}/history';
}
