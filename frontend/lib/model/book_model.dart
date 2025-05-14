
class Book {
  final int? id;
  final String title;
  final String? author;
  final String? description;
  final double? price;
  final String? publisher; // Display name
  final String? publisherId; // Database ID - new field
  final String? imageUrl;
  final String? category;
  final int? quantity;
  final int? roles;

  Book({
    this.id,
    required this.title,
    this.author,
    this.description,
    this.price,
    this.publisher,
    this.publisherId, // Add this field
    this.imageUrl,
    this.category,
    this.quantity,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'publisher': publisher,
      'publisherId': publisherId, // Include in serialization
      'image_url': imageUrl,
      'category': category,
      'quantity': quantity,
      'roles': roles,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      price: json['price']?.toDouble(),
      publisher: json['publisher'],
      publisherId: json['publisherId'], 
      imageUrl: json['image_url'],
      category: json['category'],
      quantity: json['quantity'],
      roles: json['roles'],
    );
  }
}
