import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FoodApiService {
  static const String _baseUrl = 'https://api.natfirst.in';

  String? get _apiKey => dotenv.env['food_api'];

  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'x-api-key': _apiKey ?? ''};
  }

  Future<List<dynamic>> getCategories() async {
    final url = Uri.parse('$_baseUrl/nfapi/get-categories/');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['categories'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchProducts({
    String? keyword,
    String? categoryId,
    String? barcode,
  }) async {
    final url = Uri.parse('$_baseUrl/nfapi/search/');
    final body = {};
    if (keyword != null) body['keyword'] = keyword;
    if (categoryId != null) body['category_id'] = categoryId;
    if (barcode != null) body['barcode'] = barcode;

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductDetails(String barcode) async {
    final url = Uri.parse('$_baseUrl/nfapi/get-product-details/');
    final body = {'barcode': barcode};

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return null;
    }
  }

  static Product jsonToProduct(Map<String, dynamic> json) {
    // Map the complex JSON structure from NatFirst to the OpenFoodFacts Product model
    // We construct a map that Product.fromJson can understand
    final Map<String, dynamic> offJson = {
      'code': json['barcode']?.toString(),
      'product_name': json['product_name'] ?? json['name'],
      'brands': json['brands'] ?? json['brand_name'],
      'image_front_url': json['image_url'] ?? json['image_front_url'],
      'nutrition_grades': json['nutriscore'] ?? json['nutri_score']?.toString(),
      'nova_group': json['nova_group'],
      'ingredients_text': json['ingredients_text'] ?? json['ingredients'],
      'ecoscore_grade': json['ecoscore_grade'],
      'nutriments': {
        'energy-kcal_100g': json['nutriments']?['energy'],
        'fat_100g': json['nutriments']?['fat'],
        'saturated-fat_100g': json['nutriments']?['saturated-fat'],
        'carbohydrates_100g': json['nutriments']?['carbohydrates'],
        'sugars_100g': json['nutriments']?['sugars'],
        'proteins_100g': json['nutriments']?['proteins'],
        'salt_100g': json['nutriments']?['salt'],
        'sodium_100g': json['nutriments']?['sodium'],
        'fiber_100g': json['nutriments']?['fiber'],
      },
      'ingredients': (json['ingredients_list'] as List?)
          ?.map((i) => {'text': i.toString()})
          .toList(),
    };

    return Product.fromJson(offJson);
  }
}
