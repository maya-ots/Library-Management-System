import 'book.dart';
import 'user.dart';

class Library {
  List<Book> books = [];
  List<User> users = [];

  // Add a book to the library
  void addBook(Book book) {
    books.add(book);
    print("Book added: ${book.title}");
  }

  // Show all books in the library
  void showBooks() {
    if (books.isEmpty) {
      print("No books in library.");
      return;
    }
    for (var book in books) {
      book.display();
    }
  }

  // Get a book by its ID
  Book? getBookById(int id) {
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (e) {
      return null; // Return null if not found
    }
  }

  // Optional: Find user by username
  User? getUserByUsername(String username) {
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (e) {
      return null;
    }
  }

  // Borrow a book for a user
  void borrowBook(User user, int bookId) {
    Book? book = getBookById(bookId);
    if (book == null) {
      print("Book not found");
      return;
    }
    if (!book.isAvailable) {
      print("Book already borrowed");
      return;
    }

    book.isAvailable = false;
    book.borrowCount++;
    user.borrowedBookIds.add(bookId);

    DateTime due = DateTime.now().add(Duration(days: 7));
    user.dueDates[bookId] = due.toIso8601String();

    print("Book borrowed! Due date: $due");
  }

  // Return a book for a user
  void returnBook(User user, int bookId) {
    Book? book = getBookById(bookId);
    if (book == null) return;

    book.isAvailable = true;
    user.borrowedBookIds.remove(bookId);
    user.dueDates.remove(bookId);

    print("Book returned successfully");
  }

  // Check fines for a user
  void checkFines(User user) {
    for (var entry in user.dueDates.entries) {
      DateTime due = DateTime.parse(entry.value);
      if (DateTime.now().isAfter(due)) {
        int daysLate = DateTime.now().difference(due).inDays;
        print("Book ID ${entry.key} is late by $daysLate days. Fine: \$${daysLate * 1}");
      }
    }
  }

  // Search for books by title
  List<Book> searchByTitle(String query) {
    return books.where((b) => b.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Search for books by author
  List<Book> searchByAuthor(String query) {
    return books.where((b) => b.author.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Search for books by category
  List<Book> searchByCategory(String query) {
    return books.where((b) => b.category.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Search for available books
  List<Book> searchAvailable() {
    return books.where((b) => b.isAvailable).toList();
  }

  // Fuzzy keyword search (title + author + summary)
  List<Book> fuzzySearch(String query) {
    return books.where((b) =>
        b.title.toLowerCase().contains(query.toLowerCase()) ||
        b.author.toLowerCase().contains(query.toLowerCase()) ||
        b.summary.toLowerCase().contains(query.toLowerCase())).toList();
  }


 List<Book> recommendSimilar(Book book) {
  return books.where((b) =>
      b.id != book.id &&
      (b.author == book.author || b.category == book.category)).toList();
 }

 List<Book> mostPopularBooks() {
  books.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
  return books.take(5).toList();
 }

 // Analytics dashboard
 void analyticsDashboard() {
  print("\n=== LIBRARY ANALYTICS ===");
  print("Total Books: ${books.length}");
  print("Total Users: ${users.length}");

  int borrowed = books.where((b) => !b.isAvailable).length;
  print("Borrowed Books: $borrowed");

  print("\nTop Popular Books:");
  for (var b in mostPopularBooks()) {
    print("${b.title} → borrowed ${b.borrowCount} times");
  }
 }




}