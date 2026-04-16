import 'package:equatable/equatable.dart';

/// Configuration for retrying a failed networking request.
class RetryConfig extends Equatable {
  /// Creates a [RetryConfig].
  const RetryConfig({
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 2),
  });

  /// The maximum number of retry attempts.
  /// Defaults to 3.
  final int maxRetries;

  /// The interval between retry attempts.
  /// Defaults to 2 seconds.
  final Duration retryInterval;

  @override
  List<Object?> get props => [maxRetries, retryInterval];
}
