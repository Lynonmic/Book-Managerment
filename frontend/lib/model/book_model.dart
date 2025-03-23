
class Book {
  final int? id;
  final String title;
  final String author;
  final String? description;
  final String? imageUrl;
  final double? rating; // Ensure this is a double
  final int? ratingCount;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.description,
    this.imageUrl,
    this.rating,
    this.ratingCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      // Convert the rating to double explicitly
      rating:
          json['rating'] != null
              ? double.parse(json['rating'].toString())
              : null,
      ratingCount: json['ratingCount'],
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
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
