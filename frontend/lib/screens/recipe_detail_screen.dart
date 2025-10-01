
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../models/recipe.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(recipeDetailProvider(recipeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Detail')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/recipe/$recipeId/route'),
        label: const Text('Shopping Route'),
        icon: const Icon(Icons.route),
      ),
      body: asyncDetail.when(
        data: (data) {
          final detail = RecipeDetail.fromJson(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: const Color(0xFF0071CE))),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: detail.tags.map((t) => Chip(label: Text('$t'))).toList()),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(detail.image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...detail.ingredients.map((i) => ListTile(
                  leading: const Icon(Icons.local_grocery_store),
                  title: Text('${i.name} ${i.quantity != null ? '— ${i.quantity} ${i.unit ?? ''}' : ''}'),
                  subtitle: Text(i.location != null ? 'Aisle ${i.location!['code']} • ${i.location!['area']}' : 'Location: TBD'),
                  trailing: Text(i.price != null ? '\$${i.price!.toStringAsFixed(2)}' : '—'),
                )),
                const SizedBox(height: 16),
                Text('Steps', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...detail.steps.asMap().entries.map((e) => ListTile(
                  leading: CircleAvatar(backgroundColor: const Color(0xFFFFB81C), child: Text('${e.key+1}')),
                  title: Text(e.value.toString()),
                )),
                const SizedBox(height: 16),
                if (detail.pairing != null) Card(
                  color: const Color(0xFFFFF3D0),
                  child: ListTile(
                    leading: const Icon(Icons.star),
                    title: Text('Suggested Pairing: ${detail.pairing!.title} (${detail.pairing!.type})'),
                    subtitle: Text('Find it in aisle ${detail.pairing!.aisleCode}. ${detail.pairing!.rationale}'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
