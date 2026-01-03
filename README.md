# Safe Eat 🥗

**Safe Eat** is a premium, AI-powered food safety and nutrition companion built to help users navigate the complex world of packaged foods. By combining real-time global databases with cutting-edge Generative AI, Safe Eat transforms confusing ingredient labels into clear, actionable health insights.

---

## 🌟 Importance of Safe Eat

In an era of ultra-processed foods, understanding what we eat is a challenge. Many products contain hidden sugars, harmful preservatives, and complex chemical additives. **Safe Eat** solves this by:
- **Simplifying Complexity**: Translating "chemical" ingredient lists into simple terms.
- **Personalizing Safety**: Checking products specifically against *your* age, weight, and allergies.
- **Empowering Local Communities**: Providing full support for **English, Hindi, and Asomiya** to make health information accessible to everyone.

---

## ✨ Key Features

### 🤖 Snacky AI (Multi-Modal Nutritionist)
Meet **Snacky**, your friendly AI friend. You can chat with Snacky or **upload a photo** of any food label. Snacky uses Gemini Pro Vision to analyze the contents and give you a final verdict: **Safe**, **Limit**, or **Avoid**.

### 🔍 Advanced Visual Scanner
- **Instant Magic**: Scan any barcode using the high-performance camera scanner.
- **Manual Fallback**: If a barcode is damaged, simply type the number to get instant data from the global **OpenFoodFacts** database.

### 🏠 Intelligent Home Hub
- **Dynamic News**: Stay updated with the latest in food safety regulations and nutrition trends.
- **Reddit Commmunity**: Read real-world reviews and peer insights from the global food community.
- **Pull-to-Refresh**: Your health feed stays fresh with one swipe.

### 🛒 Pre-Shopping Butler
- **USDA Exploration**: Browse 20+ food categories (Fruits, Snacks, Dairy) powered by USDA data.
- **Smart Pantry**: Build a shopping list of healthy alternatives before you even step into the store.

### 🛡️ Localized Safety Profile
Define your health baseline—allergies, height, and weight. The entire app adjusts its advice based on who you are.

---

## 🛠️ Technology Stack

- **Framework**: Flutter (Cross-platform Excellence)
- **AI Core**: Google Gemini Pro Vision
- **Backend**: Supabase (Secure Auth & User Data)
- **Databases**: OpenFoodFacts API, USDA FoodData Central
- **Social/News**: News API, Reddit API
- **State & Storage**: SharedPreferences & ValueNotifier

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- A `.env` file containing:
  ```env
  SUPABASE_URL=your_url
  SUPABASE_ANON_KEY=your_key
  GEMINI_API_KEY=your_gemini_key
  NewsAPI=your_news_key
  food_api=your_usda_key
  ```

### Installation
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to launch your journey to a healthier lifestyle.

---

## 🏛️ Architecture
Safe Eat is built following **Clean Architecture** principles, ensuring that the UI, Business Logic, and Data Services are decoupled and easy to maintain. See our [SYSTEM_DESIGN.md](./SYSTEM_DESIGN.md) for deeper technical details.

---

**Made with ❤️ for a healthier future.**