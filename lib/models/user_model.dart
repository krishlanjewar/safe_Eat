class UserModel {
  final String name;
  final int age;
  final double weight;
  final double height;
  final String dietaryPreference;
  final List<String> allergies;
  final String phone;

  UserModel({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.dietaryPreference,
    required this.allergies,
    required this.phone,
  });

  // BMI Calculation: weight (kg) / [height (m)]^2
  double get bmi {
    if (height <= 0) return 0.0;
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}
