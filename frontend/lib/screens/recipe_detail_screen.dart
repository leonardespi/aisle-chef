import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../models/recipe.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  // Track checked ingredients
  final Set<int> _checkedIngredients = {};

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(recipeDetailProvider(widget.recipeId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        // Back button with custom styling
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
          tooltip: 'Back to Recipes',
        ),
        title: Text(
          'Recipe Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      // FAB for shopping route
      floatingActionButton: asyncDetail.maybeWhen(
        data: (_) => FloatingActionButton.extended(
          onPressed: () => context.go('/recipe/${widget.recipeId}/route'),
          label: const Text(
            'Shopping Route',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.route_rounded),
          elevation: 4,
        ),
        orElse: () => null,
      ),
      body: asyncDetail.when(
        data: (data) {
          final detail = RecipeDetail.fromJson(data);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image with constrained height
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.network(
                    detail.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey[500],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe title
                      Text(
                        detail.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: detail.tags.map((tag) {
                          return Chip(
                            label: Text('$tag'),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Ingredients section
                      _SectionHeader(
                        title: 'Ingredients',
                        icon: Icons.shopping_basket_rounded,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),

                      // Ingredients list with checkboxes
                      Card(
                        elevation: 1,
                        child: Column(
                          children: detail.ingredients.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ingredient = entry.value;
                            final isChecked = _checkedIngredients.contains(index);

                            return Container(
                              decoration: BoxDecoration(
                                color: isChecked 
                                    ? Colors.green.withOpacity(0.05) 
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: index < detail.ingredients.length - 1 ? 1 : 0,
                                  ),
                                ),
                              ),
                              child: CheckboxListTile(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value ?? false) {
                                      _checkedIngredients.add(index);
                                    } else {
                                      _checkedIngredients.remove(index);
                                    }
                                  });
                                },
                                title: Text(
                                  ingredient.name,
                                  style: TextStyle(
                                    decoration: isChecked 
                                        ? TextDecoration.lineThrough 
                                        : TextDecoration.none,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (ingredient.quantity != null)
                                      Text(
                                        '${ingredient.quantity} ${ingredient.unit ?? ''}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    if (ingredient.location != null)
                                      Text(
                                        'Aisle ${ingredient.location!['code']} • ${ingredient.location!['area']}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                  ],
                                ),
                                secondary: ingredient.price != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '\$${ingredient.price!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      )
                                    : null,
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Steps section
                      _SectionHeader(
                        title: 'Cooking Steps',
                        icon: Icons.format_list_numbered_rounded,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),

                      // Steps as numbered cards
                      ...detail.steps.asMap().entries.map((entry) {
                        final stepNumber = entry.key + 1;
                        final stepText = entry.value.toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step number circle
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$stepNumber',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Step text
                                  Expanded(
                                    child: Text(
                                      stepText,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      // Pairing suggestion
                      if (detail.pairing != null) ...[
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Perfect Pairing',
                          icon: Icons.star_rounded,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Pairing icon/thumbnail
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getPairingIcon(detail.pairing!.type),
                                    color: theme.colorScheme.secondary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Pairing details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.pairing!.title ?? 'Suggested Pairing',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        detail.pairing!.type ?? '',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        detail.pairing!.rationale ?? '',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Find in Aisle ${detail.pairing!.aisleCode}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Bottom padding for FAB
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading recipe details...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load recipe',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '$err',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Recipes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPairingIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'wine':
        return Icons.wine_bar_rounded;
      case 'beverage':
      case 'drink':
        return Icons.local_drink_rounded;
      case 'dessert':
        return Icons.cake_rounded;
      case 'side':
        return Icons.restaurant_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}

// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
