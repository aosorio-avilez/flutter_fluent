import 'package:equatable/equatable.dart';

class RestApiError extends Equatable {
  const RestApiError(
    this.errorCode,
    this.message,
  );

  final String errorCode;
  final String? message;

  @override
  List<Object?> get props => [
        errorCode,
        message,
      ];
}
