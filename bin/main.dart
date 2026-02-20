import 'dart:io';
import 'package:library_system/book.dart';
import 'package:library_system/library.dart';
import 'package:library_system/storage_service.dart';
import 'package:library_system/user.dart';

void main() {
  final library = Library();
  final storage = StorageService();

  // Load persisted data
  library.books = storage.loadBooks();
  library.users = storage.loadUsers();

  // If no books persisted, add sample data
  if (library.books.isEmpty) {
    library.books.add(Book(
      1,
      '1984',
      'George Orwell',
      'Dystopian',
      summary:
          'In a chilling vision of a totalitarian future, Winston Smith wrestles with oppression '
              'in Oceania, a place where the Party scrutinizes human actions with ever-watchful Big Brother. '
              'A haunting tale about surveillance, truth, and personal freedom.',
      isbn: '978-0451524935',
    ));

    library.books.add(Book(
      2,
      'Atomic Habits',
      'James Clear',
      'Self-help',
      summary:
          'Atomic Habits offers a proven framework for improving every day. '
              'James Clear explains how tiny changes add up to remarkable results over time, '
              'and shares practical strategies to break bad habits and build good ones effectively.',
      isbn: '978-0735211292',
    ));
  }

  bool running = true;

  while (running) {
    print('\n=== LIBRARY SYSTEM ===');
    print('1. Register');
    print('2. Login');
    print('3. Show Books');
    print('4. Exit');
    stdout.write('Choose an option: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        registerUser(library, storage);
        break;
      case '2':
        loginUser(library, storage);
        break;
      case '3':
        library.showBooks();
        break;
      case '4':
        // persist before exiting
        storage.saveBooks(library.books);
        storage.saveUsers(library.users);
        print('Exiting...');
        running = false;
        break;
      default:
        print('Invalid option');
    }
  }
}

// ------------------ Register User -------------------
void registerUser(Library library, StorageService storage) {
  stdout.write('Enter username: ');
  final username = stdin.readLineSync() ?? '';
  stdout.write('Enter password: ');
  final password = stdin.readLineSync() ?? '';

  stdout.write('Choose role (admin/student): ');
  final role = stdin.readLineSync()?.toLowerCase() ?? 'student';

  if (library.users.any((u) => u.username == username)) {
    print('Username already exists!');
    return;
  }

  final newUser = User(username, password, role);
  library.users.add(newUser);
  storage.saveUsers(library.users);
  print('User registered successfully as $role');
}

// ------------------ Login User -------------------
void loginUser(Library library, StorageService storage) {
  stdout.write('Username: ');
  final username = stdin.readLineSync() ?? '';
  stdout.write('Password: ');
  final password = stdin.readLineSync() ?? '';

  User? user;
  try {
    user = library.users
        .firstWhere((u) => u.username == username && u.password == password);
  } catch (_) {
    user = null;
  }

  if (user == null) {
    print('Invalid credentials!');
    return;
  }

  print('Logged in as ${user.username} (${user.role})');

  if (user.role == 'admin') {
    adminMenu(user, library, storage);
  } else {
    studentMenu(user, library, storage);
  }
}

// ------------------ Admin Menu -------------------
void adminMenu(User user, Library library, StorageService storage) {
  bool running = true;
  while (running) {
    print('\n=== ADMIN MENU ===');
    print('1. Show Books');
    print('2. Add Book');
    print('3. Logout');
    print("4. Analytics Dashboard");

    stdout.write('Choose an option: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        library.showBooks();
        break;
      case '2':
        addBook(library);
        storage.saveBooks(library.books);
        storage.saveUsers(library.users);
        break;
      case '3':
        running = false;
        print('Logged out.');
        break;
      case '4':
        library.analyticsDashboard();
        break;
      default:
        print('Invalid option');

    }
  }
}

void addBook(Library library) {
  stdout.write('Book ID: ');
  final id = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  stdout.write('Title: ');
  final title = stdin.readLineSync() ?? '';
  stdout.write('Author: ');
  final author = stdin.readLineSync() ?? '';
  stdout.write('Category: ');
  final category = stdin.readLineSync() ?? '';

  library.addBook(Book(id, title, author, category));
}

// ------------------ Student Menu -------------------
void studentMenu(User user, Library library, StorageService storage) {
  bool running = true;
  while (running) {
    print('\n=== STUDENT MENU ===');
    print('1. Show Books');
    print('2. Borrow Books');
    print('3. Return Books');
    print('4. Check Fines');
    print("5. Search Books");
    print('6. Logout');


    stdout.write('Choose an option: ');
    final choice = stdin.readLineSync();


    switch (choice) {
       case '1':
        library.showBooks();
        break;
      case '2':
        stdout.write("Enter Book ID: ");
        int id = int.parse(stdin.readLineSync()!);

        library.borrowBook(user, id);

       //RECOMMENDATION SYSTEM HERE
       var book = library.books.firstWhere((b) => b.id == id);
       var recs = library.recommendSimilar(book);

       print("\n Recommended books:");
       for (var r in recs) {
        print("- ${r.title} by ${r.author}");
       }

       storage.saveBooks(library.books);
       storage.saveUsers(library.users);
      
       break;
      case '3':
        stdout.write("Enter Book ID: ");
        int id = int.parse(stdin.readLineSync()!);
        library.returnBook(user, id);
        storage.saveBooks(library.books);
        storage.saveUsers(library.users);
        break;
      case '4':
        library.checkFines(user);
        break;
      case '5':
        searchMenu(library);
        break;

      case '6':
        running = false;
        break;

    }
  }
}

//search menu for students
void searchMenu(Library library) {
  print("\n=== SEARCH MENU ===");
  print("1. By Title");
  print("2. By Author");
  print("3. By Category");
  print("4. Show Available Books");
  print("5. Keyword Search");
  stdout.write("Choose: ");
  String? choice = stdin.readLineSync();

  stdout.write("Enter search text: ");
  String query = stdin.readLineSync() ?? "";

  List<Book> results = [];

  switch (choice) {
    case '1':
      results = library.searchByTitle(query);
      break;
    case '2':
      results = library.searchByAuthor(query);
      break;
    case '3':
      results = library.searchByCategory(query);
      break;
    case '4':
      results = library.searchAvailable();
      break;
    case '5':
      results = library.fuzzySearch(query);
      break;
  }

  print("\n=== RESULTS ===");
  for (var b in results) {
    b.display();
  }
}

