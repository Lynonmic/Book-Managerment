import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/book/book_bloc.dart';
import 'package:frontend/blocs/category/category_bloc.dart';
import 'package:frontend/blocs/evaluation/evaluation_bloc.dart';
import 'package:frontend/blocs/forgot_pass/forgot_password_bloc.dart';
import 'package:frontend/blocs/order/order_bloc.dart';
import 'package:frontend/blocs/profile/profile_bloc.dart';
import 'package:frontend/blocs/publisher/publisher_bloc.dart';
import 'package:frontend/blocs/search/search_user_bloc.dart';
import 'package:frontend/blocs/user/user_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:frontend/repositories/book_repository.dart';
import 'package:frontend/repositories/category_repository.dart';
import 'package:frontend/repositories/evaluation_repository.dart';
import 'package:frontend/repositories/order_repository.dart';
import 'package:frontend/repositories/publisher_repository.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/screens/login/login_page.dart';
import 'package:frontend/service/api_service.dart';


void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: AuthRepository())),
        BlocProvider(create: (_) => ForgotPasswordBloc(authRepository: AuthRepository())),
        BlocProvider(create: (_) => PublisherBloc(PublisherRepository())),
        BlocProvider(create: (_) => ProfileBloc(UserRepository())),
        BlocProvider(create: (_) => UserBloc(UserRepository())),
        BlocProvider(create: (_) => BookBloc(bookRepository: BookRepository())),
        BlocProvider(create: (_) => CategoryBloc(categoryRepository: CategoryRepository())),
        BlocProvider(create: (_) => OrderBloc(orderRepository: OrderRepository())),
        BlocProvider(create: (_) => EvaluationBloc(evaluationRepository: EvaluationRepository())),
        BlocProvider(create: (_) => SearchUserBloc(ApiService()))
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
    );
  }
}