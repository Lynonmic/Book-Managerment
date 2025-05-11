class PositionFieldModel {
  final int id;
  final String name;

  PositionFieldModel({required this.id, required this.name});

  factory PositionFieldModel.fromJson(Map<String, dynamic> json) {
    return PositionFieldModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
