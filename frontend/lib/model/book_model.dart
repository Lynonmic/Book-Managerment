class BookModel {
  final int? id;
  final String title;
  final String? author;
  final String? description;
  final String? imageUrl;
  final double? rating;
  final int? ratingCount;
  final double price;
  final int quantity;
  final int? categoryId;
  final int? publisherId;

  BookModel({
    this.id,
    required this.title,
    this.author,
    this.description,
    this.imageUrl,
    this.rating,
    this.ratingCount,
    required this.price,
    required this.quantity,
    this.categoryId,
    this.publisherId,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['ma_sach'],
      title: json['ten_sach'],
      author: json['tac_gia'],
      description: json['mo_ta'],
      imageUrl: json['url_anh'],
      rating: json['danh_gia']?.toDouble(),
      ratingCount: json['so_luong_danh_gia'],
      price: json['gia'].toDouble(),
      quantity: json['so_luong'],
      categoryId: json['ma_danh_muc'],
      publisherId: json['ma_nha_xuat_ban'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_sach': id,
      'ten_sach': title,
      'tac_gia': author,
      'mo_ta': description,
      'url_anh': imageUrl,
      'danh_gia': rating,
      'so_luong_danh_gia': ratingCount,
      'gia': price,
      'so_luong': quantity,
      'ma_danh_muc': categoryId,
      'ma_nha_xuat_ban': publisherId,
    };
  }
}
