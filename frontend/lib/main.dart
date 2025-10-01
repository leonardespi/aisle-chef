import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/shopping_route_screen.dart';

void main() {
  runApp(const ProviderScope(child: AisleChefApp()));
}

class AisleChefApp extends StatelessWidget {
  const AisleChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF0071CE), // Walmart blue
      brightness: Brightness.light,
    );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (ctx, st) => const HomeScreen()),
        GoRoute(
            path: '/recipe/:id',
            builder: (ctx, st) {
              final id = int.tryParse(st.pathParameters['id'] ?? '0') ?? 0;
              return RecipeDetailScreen(recipeId: id);
            }),
        GoRoute(
            path: '/recipe/:id/route',
            builder: (ctx, st) {
              final id = int.tryParse(st.pathParameters['id'] ?? '0') ?? 0;
              return ShoppingRouteScreen(recipeId: id);
            }),
      ],
    );
    return MaterialApp.router(
      title: 'Aisle Chef',
      theme: theme.copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0071CE),
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
