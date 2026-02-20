class User {
  String username;
  String password;
  String role; // 'admin' or 'student'
  List<int> borrowedBookIds = [];
  Map<int, String> dueDates = {}; 

  User(this.username, this.password, this.role);
}
