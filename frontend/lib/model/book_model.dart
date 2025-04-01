class Book {
  final int? id;
  final String title;
  final String? author;
  final String? description;
  final double? price;
  final String? publisher;
  final String? imageUrl;
  final double? rating;
  final String? category;
  final int? quantity; // Add this
  final int? roles;

  Book({
    this.id,
    required this.title,
    this.author,
    this.description,
    this.price,
    this.publisher,
    this.imageUrl,
    this.rating,
    this.category,
    this.quantity, // Add this
    this.roles,
  });

  // Update toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'publisher': publisher,
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'quantity': quantity, // Add this
      'roles': roles,
    };
  }

  // Update fromJson method
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      price: json['price']?.toDouble(),
      publisher: json['publisher'],
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      category: json['category'],
      quantity: json['quantity'], // Add this
      roles: json['roles'],
    );
  }
}