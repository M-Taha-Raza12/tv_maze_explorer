/// API constants for TVMaze public API.
class ApiConstants {
  ApiConstants._();

  /// Base URL of TVMaze API.
  static const String baseUrl = 'https://api.tvmaze.com';

  /// Endpoints
  static const String showsEndpoint = '/shows';
  static const String searchShowsEndpoint = '/search/shows';

  /// Generates the endpoint for a single show details: `/shows/{id}`
  static String showDetailsEndpoint(int showId) => '/shows/$showId';

  /// Generates the endpoint for cast members of a show: `/shows/{id}/cast`
  static String showCastEndpoint(int showId) => '/shows/$showId/cast';

  /// Generates the endpoint for episodes of a show: `/shows/{id}/episodes`
  static String showEpisodesEndpoint(int showId) => '/shows/$showId/episodes';

  /// Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
