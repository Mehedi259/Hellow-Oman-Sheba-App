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

Page<dynamic> _buildPageWithUniqueKey(BuildContext context, GoRouterState state, Widget child) {
  final extra = state.extra;
  String uniqueId = '';
  if (extra is Map && extra.containsKey('_internal_push_id')) {
    uniqueId = extra['_internal_push_id'].toString();
  }
  return MaterialPage(
    key: ValueKey('${state.pageKey.value}_${state.uri.toString()}_$uniqueId'),
    child: child,
  );
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final isGoingToCountrySelect = state.matchedLocation == '/country-select';
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country');
    if (country == null && !isGoingToCountrySelect) {
      return '/country-select';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/country-select',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const CountrySelectScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const LoginScreen()),
    ),
    GoRoute(
      path: '/emergency',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const EmergencyScreen()),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const SearchScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const AboutScreen()),
    ),
    GoRoute(
      path: '/about-oman',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const AboutOmanScreen()),
    ),
    GoRoute(
      path: '/embassy',
      pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const EmbassyScreen()),
    ),
    GoRoute(
      path: '/services/:slug',
      pageBuilder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return _buildPageWithUniqueKey(context, state, ServiceListScreen(slug: slug));
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
          pageBuilder: (context, state) {
            final category = state.uri.queryParameters['category'];
            return _buildPageWithUniqueKey(context, state, CreatePostScreen(initialCategory: category));
          },
        ),
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const HomeScreen()),
        ),
        GoRoute(
          path: '/categories',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const CategoriesScreen()),
        ),
        GoRoute(
          path: '/special-services',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const SpecialServicesScreen()),
        ),
        GoRoute(
          path: '/classifieds',
          pageBuilder: (context, state) {
            final tab = state.uri.queryParameters['tab'];
            return _buildPageWithUniqueKey(context, state, ClassifiedsScreen(key: ValueKey('classifieds_$tab'), initialTab: tab));
          },
        ),
        GoRoute(
          path: '/community',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const CommunityScreen()),
        ),
        GoRoute(
          path: '/news',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const NewsFeedScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const ProfileScreen()),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const NotificationsScreen()),
        ),
        GoRoute(
          path: '/my-listings',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const MyListingsScreen()),
        ),
        GoRoute(
          path: '/messages',
          pageBuilder: (context, state) => _buildPageWithUniqueKey(context, state, const MessagesScreen()),
        ),
      ],
    ),
  ],
);
