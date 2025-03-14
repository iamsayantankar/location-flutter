/// A utility class that contains API endpoint URLs for the application.
///
/// This class helps in managing all API URLs centrally, making it easier
/// to update the base URL and modify endpoints when needed.
class UrlHelper {
  /// Base URL for the API.
  static const String _url = "https://ecb0-103-211-132-40.ngrok-free.app/";
  /* Todo: update instruction for update the _url
  1. add only url with http or https
  2. Add "/" at the end point of the url
   */

  // ======================== API Endpoints ========================

  /// Endpoint for user login.
  static const String logInUrl = "${_url}login.php";

  /// Endpoint to fetch all tourist data.
  static const String getDataUrl = "${_url}get-data.php?request=allTourist";

  /// Endpoint to fetch all states data.
  static const String getStateUrl = "${_url}get-data.php?request=allState";

  /// Endpoint to retrieve liked items.
  static const String getLikeUrl = "${_url}get-data.php?request=getLike";

  /// Endpoint to toggle like status.
  static const String setLikeUrl = "${_url}get-data.php?request=switchLike";

  /// Endpoint to fetch all favorite items.
  static const String getFavouritesUrl = "${_url}get-data.php?request=getFavourites";
}
