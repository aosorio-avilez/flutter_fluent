## fluent_networking
Package that provides a simple way to make http requests

## Getting Started

### Add dependencies

```yaml
fluent_networking: ^0.9.0
```

### Create networking config

Configure your base URL, global headers, and enable built-in interceptors like Cache, Retry, and Logging.

```dart
class ApiConfig extends NetworkingConfig {
  @override
  String get baseUrl => "https://pokeapi.co/api/v2";

  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  @override
  List<Interceptor> get interceptors => [
    // Automatically retry failed requests (3 times by default)
    NetworkingRetryInterceptor(),
    // Cache responses locally
    NetworkingCacheInterceptor(),
    // Log requests and responses (with sensitive data redacting)
    NetworkingLogInterceptor(),
  ];
}
```

### Build module

```dart
void main() async {
  await Fluent.build([
    NetworkingModule(config: ApiConfig()),
  ]);

  runApp(const MainApp());
}
```

### Use it

The API uses `ResponseResult` to force you to handle both success and failure cases safely.

#### GET request

```dart
final networkingApi = Fluent.get<NetworkingApi>();

final result = await networkingApi.get<Map<String, dynamic>>(
    "/pokemon/pikachu",
    queryParams: {"include_details": "true"},
);

if (result is Success) {
    print("Data: ${result.data}");
}
```

#### POST request

```dart
final result = await networkingApi.post<Map<String, dynamic>>(
    "/orders",
    data: {"product_id": 1, "quantity": 10},
    headers: {"X-Custom-Header": "Value"},
);
```

## Logging & Security

The package includes a `NetworkingLogInterceptor` that automatically formats and logs HTTP requests and responses. It also includes built-in security features to protect sensitive data:

- **Sensitive Key Redacting**: Keys like `password`, `token`, `secret`, `api_key`, `email`, `credit_card`, and `phone_number` are automatically redacted in the logs.
- **FormData Sanitization**: Sensitive fields in `multipart/form-data` requests are also identified and masked.
- **Production Safety**: Logging is automatically optimized for production environments.

## Custom Interceptors

You can easily create your own interceptors by extending `NetworkingInterceptor`:

```dart
class AuthInterceptor extends NetworkingInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = myAuthService.getToken();
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_networking_example.gif" width="400" />