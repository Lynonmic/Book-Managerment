import 'package:equatable/equatable.dart';

class EvaluationModel extends Equatable {
  final String? id;
  final String? bookId;
  final String? userId;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userName; // For display purposes
  final String? bookTitle; // For display purposes

  const EvaluationModel({
    this.id,
    this.bookId,
    this.userId,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.bookTitle,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id']?.toString(),
      bookId: json['bookId']?.toString(),
      userId: json['userId']?.toString(),
      rating: json['rating'] != null ? (json['rating'] as num).toInt() : null,
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      userName: json['userName'],
      bookTitle: json['bookTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userName': userName,
      'bookTitle': bookTitle,
    };
  }
  
  @override
  List<Object?> get props => [id, bookId, userId, rating, comment, createdAt, updatedAt, userName, bookTitle];
}
