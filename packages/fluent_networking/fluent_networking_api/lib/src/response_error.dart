import 'package:equatable/equatable.dart';

class ResponseError extends Equatable {
  const ResponseError(
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
