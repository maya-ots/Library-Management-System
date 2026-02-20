class Book {
  int id;
  String title;
  String author;
  String category;
  bool isAvailable;
  int borrowCount;
  String summary; 
  String isbn;    

  Book(this.id, this.title, this.author, this.category,
      {this.isAvailable = true,
      this.borrowCount = 0,
      this.summary = "",
      this.isbn = ""});

  void display() {
    print(
        "$id. $title by $author [$category] - ${isAvailable ? 'Available' : 'Borrowed'}");
         if (summary.isNotEmpty) {
      print("   Summary: $summary");
    }
    if (isbn.isNotEmpty) {
      print("   ISBN: $isbn");
    }
  }
}
