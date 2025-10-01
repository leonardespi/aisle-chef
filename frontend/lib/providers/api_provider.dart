
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final recipesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getRecipes();
});

final recipeDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  return api.getRecipe(id);
});

final routeProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  return api.getRoute(id);
});
