import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_event.dart';
import 'package:frontend/blocs/evaluation/evaluation_state.dart';
import 'package:frontend/model/evaluation_model.dart';
import 'package:frontend/screens/widget/floating_button.dart';

class EvaluationListScreen extends StatelessWidget {
  const EvaluationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EvaluationBloc, EvaluationState>(
      builder: (context, state) {
        if (state.status == EvaluationStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.status == EvaluationStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage ?? 'An error occurred',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<EvaluationBloc>().add(LoadAllReviews()),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state.reviews.isEmpty) {
          return Center(child: Text('No reviews found'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<EvaluationBloc>().add(LoadAllReviews());
                return Future.delayed(Duration(milliseconds: 300));
              },
              child: ListView.builder(
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  final evaluation = state.reviews[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Row(
                        children: [
                          Text(
                            evaluation.bookTitle ?? 'Unknown Book',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          _buildRatingStars(evaluation.rating),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('By: ${evaluation.userName ?? 'Anonymous'}'),
                          SizedBox(height: 4),
                          Text(evaluation.comment ?? 'No comment'),
                          SizedBox(height: 4),
                          Text(
                            'Date: ${evaluation.createdAt != null ? evaluation.createdAt!.toString().substring(0, 10) : 'Unknown'}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditEvaluationDialog(context, evaluation);
                          } else if (value == 'delete') {
                            _showDeleteEvaluationConfirmationDialog(context, evaluation);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingButton(
                onPressed: () {
                  // Create new evaluation
                  // This would typically navigate to a book selection screen first
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Select a book to review from the Books tab')),
                  );
                },
                tooltip: 'Add Review',
                backgroundColor: Colors.amber,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingStars(int? rating) {
    final int starCount = rating ?? 0;
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < starCount ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  void _showEditEvaluationDialog(BuildContext context, EvaluationModel evaluation) {
    final TextEditingController commentController = TextEditingController(text: evaluation.comment);
    int selectedRating = evaluation.rating ?? 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Book: ${evaluation.bookTitle ?? 'Unknown Book'}'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final updatedEvaluation = EvaluationModel(
                      id: evaluation.id,
                      userId: evaluation.userId,
                      bookId: evaluation.bookId,
                      rating: selectedRating,
                      comment: commentController.text.trim(),
                      userName: evaluation.userName,
                      bookTitle: evaluation.bookTitle,
                      createdAt: evaluation.createdAt,
                      updatedAt: DateTime.now(),
                    );
                    context.read<EvaluationBloc>().add(UpdateReview(evaluation.id!, updatedEvaluation));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Review updated')),
                    );
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteEvaluationConfirmationDialog(BuildContext context, EvaluationModel evaluation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Review'),
          content: Text('Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<EvaluationBloc>().add(DeleteReview(evaluation.id!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Review deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
