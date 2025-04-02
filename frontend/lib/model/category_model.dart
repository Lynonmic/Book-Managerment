class CategoryModel {
  final int? id;
  final String name; // Changed from tenDanhMuc to match JSON structure

  CategoryModel({this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '', // Changed from 'ten_danh_muc' to 'name'
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
