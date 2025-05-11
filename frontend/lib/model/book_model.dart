class Book {
  final int? id;
  final String title;
  final String author;
  final String description;
  final double price;
  final String? imageUrl;
  final String? category;
  final int quantity;
  final int? publisherId;
  final String? publisherName;
  // Add location fields
  final String? shelf;
  final String? warehouse;
  final String? position;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
    required this.quantity,
    this.publisherId,
    this.publisherName,
    // Add location parameters
    this.shelf,
    this.warehouse,
    this.position,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      category: json['category'],
      quantity: json['quantity'],
      publisherId: json['publisher_id'],
      publisherName: json['publisher_name'],
      // Add location fields from JSON
      shelf: json['shelf'],
      warehouse: json['warehouse'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'quantity': quantity,
      'publisher_id': publisherId,
      'publisher_name': publisherName,
      'shelf': shelf,
      'warehouse': warehouse,
      'position': position,
    };
  }
}
