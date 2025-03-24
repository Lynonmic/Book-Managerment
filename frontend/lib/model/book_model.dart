import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final String author;
  final String? description;
  final String? imageUrl;
  final double? rating; // Ensure this is a double
  final int? ratingCount;
  final double? price;
  final int roles; // 1 for admin, 0 for regular user

  Book({
    this.id,
    required this.title,
    required this.author,
    this.description,
    this.imageUrl,
    this.rating,
    this.ratingCount,
    this.price,
    this.roles = 0, // Default to regular user
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Print the JSON to debug
    print('Book JSON: $json');

    return Book(
      id: json['id'],
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      description: json['description'],
      imageUrl: json['imageUrl'],
      // Convert the rating to double explicitly
      rating:
          json['rating'] != null
              ? double.parse(json['rating'].toString())
              : null,
      ratingCount: json['ratingCount'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      // Ensure roles is properly parsed from the JSON
      roles:
          json.containsKey('roles') ? int.parse(json['roles'].toString()) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'price': price,
      'roles': roles,
    };
  }

  // Create a copy with updated fields
  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? description,
    String? imageUrl,
    double? rating,
    int? ratingCount,
    double? price,
    int? roles,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      price: price ?? this.price,
      roles: roles ?? this.roles,
    );
  }
}
