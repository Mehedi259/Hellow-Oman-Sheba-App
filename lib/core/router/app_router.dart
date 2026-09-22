import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/home/main_scaffold.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/classifieds/classifieds_screen.dart';
import '../../presentation/community/community_screen.dart';
import '../../presentation/news/news_feed_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/emergency/emergency_screen.dart';
import '../../presentation/country_select/country_select_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/search/search_screen.dart';
import '../../presentation/notifications/notifications_screen.dart';
import '../../presentation/messages/messages_screen.dart';
import '../../presentation/my_listings/my_listings_screen.dart';
import '../../presentation/info/info_screens.dart';
import '../../presentation/info/about_oman_screen.dart';
import '../../presentation/info/embassy_screen.dart';
import '../../presentation/categories/service_list_screen.dart';
import '../../presentation/categories/categories_screen.dart';
import '../../presentation/post/create_post_screen.dart';
import '../../presentation/special_services/special_services_screen.dart';
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    // Only check redirect if we are not already going to country-select
    final isGoingToCountrySelect = state.matchedLocation == '/country-select';
    
    // We check shared preferences synchronously if possible, but redirect is async.
    // However, GoRouter's async redirect can cause a flicker.
    // For a cleaner solution, we use async redirect.
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country');
    
    // If no country is selected, force them to the country select screen
    if (country == null && !isGoingToCountrySelect) {
      return '/country-select';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/country-select',
      builder: (context, state) => const CountrySelectScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/about-oman',
      builder: (context, state) => const AboutOmanScreen(),
    ),
    GoRoute(
      path: '/embassy',
      builder: (context, state) => const EmbassyScreen(),
    ),
    GoRoute(
      path: '/services/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return ServiceListScreen(slug: slug);
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/post/create',
          builder: (context, state) {
            final category = state.uri.queryParameters['category'];
            return CreatePostScreen(initialCategory: category);
          },
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/special-services',
          builder: (context, state) => const SpecialServicesScreen(),
        ),
        GoRoute(
          path: '/classifieds',
          builder: (context, state) {
            final tab = state.uri.queryParameters['tab'];
            return ClassifiedsScreen(key: ValueKey('classifieds_$tab'), initialTab: tab);
          },
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/news',
          builder: (context, state) => const NewsFeedScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/my-listings',
          builder: (context, state) => const MyListingsScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
      ],
    ),
  ],
);
