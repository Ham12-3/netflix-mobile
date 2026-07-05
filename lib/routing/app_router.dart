import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth_screen.dart';
import '../screens/details_screen.dart';
import '../screens/home_screen.dart';
import '../screens/player_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/watchlist_screen.dart';
import '../state/providers.dart';
import '../widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/signup';

      if (auth.isLoading) {
        return path == '/splash' ? null : '/splash';
      }

      if (!auth.isSignedIn) {
        return isAuthRoute ? null : '/login';
      }

      if (path == '/splash' || isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(mode: AuthMode.login),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AuthScreen(mode: AuthMode.signup),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/watchlist',
            builder: (context, state) => const WatchlistScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/movie/:id',
            builder: (context, state) {
              return DetailsScreen(movieId: state.pathParameters['id']!);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/watch/:id',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: PlayerScreen(movieId: state.pathParameters['id']!),
        ),
      ),
    ],
  );
});
