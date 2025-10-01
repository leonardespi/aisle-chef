
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../models/recipe.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecipes = ref.watch(recipesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aisle Chef')),
      body: asyncRecipes.when(
        data: (data) {
          final cards = data.map((e) => RecipeCard.fromJson(e)).toList();
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3/4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (ctx, i) {
              final r = cards[i];
              return InkWell(
                onTap: () => context.go('/recipe/${r.id}'),
                child: Card(
                  elevation: 1.5,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(r.image, fit: BoxFit.cover, width: double.infinity),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(r.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          spacing: 6,
                          children: r.tags.take(3).map((t) => Chip(label: Text('$t'))).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
