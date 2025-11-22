/// A sealed class representing the result of an operation
/// that can either succeed or fail.
///
/// This allows for explicit handling of both success and failure cases,
/// making the return types more robust and readable.
sealed class ResponseResult<T> {
  const ResponseResult();
}

/// Represents a successful result of an operation.
///
/// Contains the data returned by the successful operation.
class Success<T> extends ResponseResult<T> {
  /// Creates a [Success] with the given [data].
  const Success(this.data);

  /// The data returned by the successful operation.
  final T data;
}

/// Represents a failed result of an operation.
///
/// Contains an [HttpError] object detailing the nature of the failure.
class Failure<T> extends ResponseResult<T> {
  /// Creates a [Failure] with the given [error].
  const Failure(this.error);

  /// The error information describing the failure.
  final HttpError error;
}

/// Represents an HTTP-related error that occurred during an operation.
class HttpError {
  /// Creates an [HttpError] with a required [message]
  /// and optional [code] and [data].
  HttpError({required this.message, this.code, this.data});

  /// An optional HTTP status code or a custom error code.
  final int? code;

  /// A descriptive message explaining the error.
  final String message;

  /// Optional additional data related to the error, which can be of any type.
  final dynamic data;
}
