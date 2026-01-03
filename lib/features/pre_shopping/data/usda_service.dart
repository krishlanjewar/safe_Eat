import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A data model representing a food item returned from the USDA FoodData Central API.
class USDAFoodItem {
  final String fdcId;
  final String description;
  final String? brandOwner;
  final List<Map<String, dynamic>> nutrients;
  final String? ingredients;

  USDAFoodItem({
    required this.fdcId,
    required this.description,
    this.brandOwner,
    required this.nutrients,
    this.ingredients,
  });

  factory USDAFoodItem.fromJson(Map<String, dynamic> json) {
    final nutrientsList = (json['foodNutrients'] as List? ?? [])
        .map(
          (n) => {
            'name': n['nutrientName'],
            'amount': n['value'],
            'unit': n['unitName'],
          },
        )
        .toList();

    return USDAFoodItem(
      fdcId: json['fdcId'].toString(),
      description: json['description'] ?? 'No Description',
      brandOwner: json['brandOwner'],
      nutrients: nutrientsList,
      ingredients: json['ingredients'],
    );
  }
}

/// A service that communicates with the USDA FoodData Central API.
///
/// Used for category-based exploration and retrieving detailed food data
/// not present in other databases.
class USDAService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  Future<List<USDAFoodItem>> searchFoods(String query) async {
    final apiKey = dotenv.env['food_api'];
    if (apiKey == null) throw Exception('USDA API key not found');

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/foods/search?query=${Uri.encodeComponent(query)}&pageSize=20&api_key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List foods = data['foods'];
      return foods.map((f) => USDAFoodItem.fromJson(f)).toList();
    } else {
      throw Exception('Failed to search foods from USDA');
    }
  }

  Future<USDAFoodItem> getFoodDetails(String fdcId) async {
    final apiKey = dotenv.env['food_api'];
    if (apiKey == null) throw Exception('USDA API key not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/food/$fdcId?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      return USDAFoodItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch food details from USDA');
    }
  }
}
