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
    };
  }
}
