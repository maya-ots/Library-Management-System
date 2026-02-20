import 'dart:convert';
import 'dart:io';
import 'book.dart';
import 'user.dart';

class StorageService {
  final String booksFile = "books.json";
  final String usersFile = "users.json";

  // Save books to JSON
  void saveBooks(List<Book> books) {
    List<Map<String, dynamic>> jsonList =
        books.map((b) => {
              'id': b.id,
              'title': b.title,
              'author': b.author,
              'category': b.category,
              'isAvailable': b.isAvailable,
              'borrowCount': b.borrowCount,
            }).toList();

    File(booksFile).writeAsStringSync(jsonEncode(jsonList));
  }

  // Load books from JSON
  List<Book> loadBooks() {
    if (!File(booksFile).existsSync()) return [];

    String jsonString = File(booksFile).readAsStringSync();
    List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map((b) => Book(b['id'], b['title'], b['author'], b['category'],
            isAvailable: b['isAvailable'], borrowCount: b['borrowCount']))
        .toList();
  }

  // Save users to JSON
  void saveUsers(List<User> users) {
    List<Map<String, dynamic>> jsonList = users.map((u) => {
          'username': u.username,
          'password': u.password,
          'role': u.role,
          'borrowedBookIds': u.borrowedBookIds,
        }).toList();

    File(usersFile).writeAsStringSync(jsonEncode(jsonList));
  }

  // Load users from JSON
  List<User> loadUsers() {
    if (!File(usersFile).existsSync()) return [];

    String jsonString = File(usersFile).readAsStringSync();
    List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map((u) => User(u['username'], u['password'], u['role'])
          ..borrowedBookIds = List<int>.from(u['borrowedBookIds']))
        .toList();
  }
}
