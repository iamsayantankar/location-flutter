# Flutter Tourist App

This is a Flutter-based mobile application that provides users with information about tourist spots, nearby shops, and available guides. It includes features such as Google Maps integration, user authentication, and a like/dislike system for tourist spots.

## Features
- **Google Maps Integration**: View tourist locations on an interactive map.
- **User Authentication**: Login system using `SharedPreferences`.
- **Like/Dislike System**: Users can like or unlike tourist spots.
- **Nearby Shops & Guides**: Information on local shops and available guides.
- **Theming**: Light and dark theme support.

## Installation

### Prerequisites
Ensure you have Flutter installed. If not, follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install).

### Steps to Run the Project
1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo/tourist-app.git
   ```
2. Navigate to the project folder:
   ```sh
   cd tourist-app
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Run the app:
   ```sh
   flutter run
   ```

## File Structure
```
frontend_flutter_code/
│── lib/
│   ├── main.dart          # Main entry point of the app
│   ├── screens/           # All screen UI components
│   ├── utils/
│   │   ├── helper/
│   │   │   ├── url_helper.dart  # Manages API URLs
│   ├── widgets/          # Reusable UI components
│   ├── services/         # API and data handling
│── pubspec.yaml          # Dependencies and assets
```

## Update API URL

Follow these steps to update the API URL in the project:

1. Go to the project folder.
2. Navigate to:
   ```sh
   frontend_flutter_code/lib/utils/helper/url_helper.dart
   ```
3. Go to **Line Number 7**.
4. Add the API URL with **http** or **https**.
5. Ensure the URL ends with `/` (slash) at the endpoint.

Example:
```dart
class UrlHelper {
  static const String getLikeUrl = "https://example.com/api/like/";
}
```

## Contributions
Pull requests are welcome. Please ensure that your changes are well-tested before submitting.

## License
This project is licensed under the MIT License.

# location-flutter
