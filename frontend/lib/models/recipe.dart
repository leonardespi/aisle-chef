
class IngredientItem {
  final String name;
  final num? quantity;
  final String? unit;
  final num? price;
  final Map<String, dynamic>? location;
  final List<dynamic>? substitutes;
  final bool missing;

  IngredientItem({
    required this.name,
    this.quantity,
    this.unit,
    this.price,
    this.location,
    this.substitutes,
    required this.missing,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      price: json['price'],
      location: json['location'],
      substitutes: json['substitutes'],
      missing: json['missing'] ?? false,
    );
  }
}

class Pairing {
  final int? id;
  final int? recipeId;
  final String? type;
  final String? title;
  final String? aisleCode;
  final String? rationale;

  Pairing({this.id, this.recipeId, this.type, this.title, this.aisleCode, this.rationale});

  factory Pairing.fromJson(Map<String, dynamic> json) {
    return Pairing(
      id: json['id'],
      recipeId: json['recipe_id'],
      type: json['type'],
      title: json['title'],
      aisleCode: json['aisle_code'],
      rationale: json['rationale'],
    );
  }
}

class RecipeCard {
  final int id;
  final String title;
  final List<dynamic> tags;
  final String image;

  RecipeCard({required this.id, required this.title, required this.tags, required this.image});

  factory RecipeCard.fromJson(Map<String, dynamic> json) {
    return RecipeCard(
      id: json['id'],
      title: json['title'],
      tags: json['tags'] ?? [],
      image: json['image'],
    );
  }
}

class RecipeDetail {
  final int id;
  final String title;
  final List<dynamic> tags;
  final String image;
  final List<dynamic> steps;
  final List<IngredientItem> ingredients;
  final Pairing? pairing;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.tags,
    required this.image,
    required this.steps,
    required this.ingredients,
    this.pairing,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    final items = (json['ingredients'] as List).map((e) => IngredientItem.fromJson(e)).toList();
    return RecipeDetail(
      id: json['id'],
      title: json['title'],
      tags: json['tags'] ?? [],
      image: json['image'],
      steps: (json['steps'] as List),
      ingredients: items,
      pairing: json['pairing'] != null ? Pairing.fromJson(json['pairing']) : null,
    );
  }
}
