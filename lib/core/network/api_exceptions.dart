/// Base exception for API network requests.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}

/// Thrown when there is no network connection or a timeout occurs.
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network connection failed. Please check your internet.']);
}

/// Thrown when a resource (e.g. show, episode, cast) is not found (HTTP 404).
class NotFoundException extends ApiException {
  const NotFoundException([String message = 'The requested resource was not found.'])
      : super(message, 404);
}

/// Thrown when the server returns a 5xx response.
class ServerException extends ApiException {
  const ServerException([String message = 'TVMaze server error. Please try again later.'])
      : super(message, 500);
}

/// Thrown when parsing response data fails.
class DataParsingException extends ApiException {
  const DataParsingException([super.message = 'Failed to process data from the server.']);
}
