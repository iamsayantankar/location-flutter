import 'package:flutter/material.dart';

/// A utility class to store global variables for the app.
class GlobalVariable {
  /// A global key used to access the app's [NavigatorState].
  ///
  /// This allows navigation operations (e.g., pushing or popping routes)
  /// to be performed anywhere in the app without needing a `BuildContext`.
  static final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();
}
