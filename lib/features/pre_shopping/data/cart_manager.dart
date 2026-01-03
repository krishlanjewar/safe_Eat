import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents an item in the user's pantry or shopping list.
class FoodItem {
  final String name;
  final IconData imageIcon;
  final int calories;
  final double protein;
  final bool isHealthy;
  final String description;
  bool isBought;
  int quantity;

  FoodItem({
    required this.name,
    required this.imageIcon,
    required this.calories,
    required this.protein,
    required this.isHealthy,
    required this.description,
    this.isBought = false,
    this.quantity = 1,
  });

  FoodItem copyWith({bool? isBought, int? quantity}) {
    return FoodItem(
      name: name,
      imageIcon: imageIcon,
      calories: calories,
      protein: protein,
      isHealthy: isHealthy,
      description: description,
      isBought: isBought ?? this.isBought,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': imageIcon.codePoint,
      'calories': calories,
      'protein': protein,
      'isHealthy': isHealthy,
      'description': description,
      'isBought': isBought,
      'quantity': quantity,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      imageIcon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      calories: json['calories'],
      protein: json['protein'],
      isHealthy: json['isHealthy'],
      description: json['description'],
      isBought: json['isBought'] ?? false,
      quantity: json['quantity'] ?? 1,
    );
  }
}

/// A singleton manager that handles the persistence and state of the shopping cart.
///
/// It uses `SharedPreferences` to ensure the user's list is saved between sessions.
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal() {
    loadCart();
  }

  final ValueNotifier<List<FoodItem>> cartItems = ValueNotifier<List<FoodItem>>(
    [],
  );
  static const String _storageKey = 'shopping_cart_items';

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      cartItems.value.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      cartItems.value = decodedData
          .map((item) => FoodItem.fromJson(item))
          .toList();
    }
  }

  void addItem(FoodItem item) {
    final List<FoodItem> newList = List.from(cartItems.value);
    final existingIndex = newList.indexWhere((i) => i.name == item.name);

    if (existingIndex != -1) {
      newList[existingIndex] = newList[existingIndex].copyWith(
        quantity: newList[existingIndex].quantity + 1,
      );
    } else {
      newList.add(item.copyWith(isBought: false, quantity: 1));
    }
    cartItems.value = newList;
    saveCart();
  }

  void updateQuantity(int index, int delta) {
    final List<FoodItem> newList = List.from(cartItems.value);
    final newQty = newList[index].quantity + delta;
    if (newQty > 0) {
      newList[index] = newList[index].copyWith(quantity: newQty);
      cartItems.value = newList;
    } else {
      newList.removeAt(index);
      cartItems.value = newList;
    }
    saveCart();
  }

  void toggleItemBought(int index) {
    final List<FoodItem> newList = List.from(cartItems.value);
    newList[index] = newList[index].copyWith(
      isBought: !newList[index].isBought,
    );
    cartItems.value = newList;
    saveCart();
  }

  void removeItem(int index) {
    cartItems.value = List.from(cartItems.value)..removeAt(index);
    saveCart();
  }

  void clearCart() {
    cartItems.value = [];
    saveCart();
  }

  double get totalCalories => cartItems.value.fold(
    0,
    (sum, item) => sum + (item.calories * item.quantity),
  );
  double get totalProtein => cartItems.value.fold(
    0,
    (sum, item) => sum + (item.protein * item.quantity),
  );

  int get totalItemCount =>
      cartItems.value.fold(0, (sum, item) => sum + item.quantity);

  int get healthyCount =>
      cartItems.value.where((item) => item.isHealthy).length;
  int get unhealthyCount => cartItems.value.length - healthyCount;
}

final cartManager = CartManager();
