
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? 'http://127.0.0.1:8000';

  Future<List<dynamic>> getRecipes() async {
    final resp = await http.get(Uri.parse('$baseUrl/recipes'));
    if (resp.statusCode != 200) throw Exception('Failed to load recipes');
    return jsonDecode(resp.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getRecipe(int id) async {
    final resp = await http.get(Uri.parse('$baseUrl/recipes/$id'));
    if (resp.statusCode == 404) throw Exception('Recipe not found');
    if (resp.statusCode != 200) throw Exception('Failed to load recipe');
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRoute(int id) async {
    final resp = await http.get(Uri.parse('$baseUrl/recipes/$id/route'));
    if (resp.statusCode != 200) throw Exception('Failed to load route');
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
