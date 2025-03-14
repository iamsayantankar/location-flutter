import 'package:flutter/material.dart';
import 'package:sd_project/screens/entry_screen.dart';
import 'package:sd_project/screens/home_screen.dart';
import 'package:sd_project/utils/helper/shared_preferences_helper.dart';
import 'package:sd_project/utils/permission/permissions.dart';
import 'package:sd_project/utils/services/global.dart';
import 'package:sd_project/utils/theme/theme_constants.dart';
import 'package:sd_project/utils/theme/theme_manager.dart';

void main() async {
  // Ensures Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Request all necessary app permissions (e.g., storage, location, etc.)
  await AppPermissions.requestAllPermissions();

  // Initialize SharedPreferences to persist user data locally
  await SharedPreferencesHelper.init();

  // Retrieve the stored user email to check login status
  String? userEmail = await SharedPreferencesHelper.getString("user_email");

  // Run the Flutter application, passing the retrieved email to MyApp
  runApp(MyApp(userEmail: userEmail ?? ""));
}

// ThemeManager instance to manage light and dark theme switching
ThemeManager _themeManager = ThemeManager();

class MyApp extends StatelessWidget {
  // User email retrieved from SharedPreferences
  final String? userEmail;

  // Constructor to initialize MyApp with the user email
  const MyApp({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Global navigator key for managing navigation state across the app
      navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: false, // Hides the debug banner

      title: 'Flutter Demo', // Application title

      // Define light and dark themes
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode, // Dynamically switch themes

      // Determine the home screen based on login status
      home: (userEmail!.isNotEmpty && userEmail != "")
          ? const HomeScreen() // If user is logged in, navigate to HomeScreen
          : const EntryScreen(), // Otherwise, show EntryScreen (login/signup)
    );
  }
}
