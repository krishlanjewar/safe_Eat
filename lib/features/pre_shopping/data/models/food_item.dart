import 'package:flutter/material.dart';

class FoodItem {
  final String name;
  final IconData imageIcon;
  final int calories;
  final double protein;
  final bool isHealthy;
  final String description;

  FoodItem({
    required this.name,
    required this.imageIcon,
    required this.calories,
    required this.protein,
    required this.isHealthy,
    required this.description,
  });
}
