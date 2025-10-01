
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';

class ShoppingRouteScreen extends ConsumerWidget {
  final int recipeId;
  const ShoppingRouteScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRoute = ref.watch(routeProvider(recipeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Route')),
      body: asyncRoute.when(
        data: (data) {
          final List<dynamic> route = data['route'] ?? [];
          if (route.isEmpty) {
            return const Center(child: Text('No route available for this recipe.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: route.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final item = route[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${i+1}')),
                title: Text('${item['code']} — ${item['name']}'),
                subtitle: Text('Position: ${item['index']}'),
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
