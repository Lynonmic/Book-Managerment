import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_event.dart';
import 'package:frontend/blocs/evaluation/evaluation_state.dart';
import 'package:frontend/blocs/user/user_bloc.dart';
import 'package:frontend/blocs/user/user_state.dart';
import 'package:frontend/model/evaluation_model.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/screens/widget/floating_button.dart';

class EvaluationListScreen extends StatelessWidget {
  const EvaluationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluations/Reviews'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (userState is UserError) {
            return Center(child: Text('Error loading users: ${userState.message}'));
          } else if (userState is UserLoaded) {
            final userMap = <int, UserModels>{};
            for (var user in userState.users) {
              if (user.maKhachHang != null) {
                userMap[user.maKhachHang!] = user;
              }
            }

            return BlocBuilder<EvaluationBloc, EvaluationState>(
              builder: (context, evaluationState) {
                if (evaluationState.status == EvaluationStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (evaluationState.status == EvaluationStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          evaluationState.errorMessage ?? 'An error occurred',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<EvaluationBloc>().add(LoadAllReviews()),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (evaluationState.reviews.isEmpty) {
                  return const Center(child: Text('No reviews found'));
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<EvaluationBloc>().add(LoadAllReviews());
                        return Future.delayed(const Duration(milliseconds: 300));
                      },
                      child: ListView.builder(
                        itemCount: evaluationState.reviews.length,
                        itemBuilder: (context, index) {
                          final evaluation = evaluationState.reviews[index];

                          final int? userIdInt = int.tryParse(evaluation.userId ?? '');
                          final UserModels? user = (userIdInt != null) ? userMap[userIdInt] : null;

                          final String displayName = user?.tenKhachHang ?? evaluation.userName ?? 'Anonymous';
                          final String displayId = user?.maKhachHang?.toString() ?? evaluation.userId ?? 'N/A';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              evaluation.bookTitle ?? 'Unknown Book',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 8),
                                            Text('By: $displayName ($displayId)', softWrap: true),
                                            const SizedBox(height: 4),
                                            Text(evaluation.comment ?? 'No comment', softWrap: true),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Date: ${evaluation.createdAt != null ? evaluation.createdAt!.toString().substring(0, 10) : 'Unknown'}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        constraints: const BoxConstraints(maxWidth: 35.0),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditEvaluationDialog(context, evaluation);
                                          } else if (value == 'delete') {
                                            _showDeleteEvaluationConfirmationDialog(context, evaluation);
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildRatingStars(evaluation.rating),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select a book to review from the Books tab')),
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
          } else {
            return const Center(child: Text('Loading user data...'));
          }
        },
      ),
    );
  }

  Widget _buildRatingStars(int? rating) {
    final int starCount = rating ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < starCount ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 10,
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
              title: const Text('Edit Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Book: ${evaluation.bookTitle ?? 'Unknown Book'}'),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
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
                  child: const Text('Cancel'),
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
                      const SnackBar(content: Text('Review updated')),
                    );
                  },
                  child: const Text('Update'),
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
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<EvaluationBloc>().add(DeleteReview(evaluation.id!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
