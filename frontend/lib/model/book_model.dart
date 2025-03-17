class BookModel {
  final int? id;
  final String title;
  final String author;
  final String? description;
  final String? imageUrl;
  final double? price;
  final String? publisher;
  final int? pageCount;
  final String? isbn;
  final String? createdAt;
  final String? updatedAt;
  final double? rating;
  final int? ratingCount;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    this.description,
    this.imageUrl,
    this.price,
    this.publisher,
    this.pageCount,
    this.isbn,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.ratingCount,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      publisher: json['publisher'],
      pageCount: json['pageCount'],
      isbn: json['isbn'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rating: json['rating']?.toDouble(),
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
      'price': price,
      'publisher': publisher,
      'pageCount': pageCount,
      'isbn': isbn,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }
}
