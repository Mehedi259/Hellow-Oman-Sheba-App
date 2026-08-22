import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/auth/login_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Add other routes here: classifieds, community, news, emergency, profile
  ],
);
