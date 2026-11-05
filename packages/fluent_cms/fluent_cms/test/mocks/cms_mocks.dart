import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerApi extends Mock implements LoggerApi {}

class MockNetworkingApi extends Mock implements NetworkingApi {}

class MockEnvironmentApi extends Mock implements EnvironmentApi {}

class MockRegistry extends Mock implements Registry {}

class MockCmsApi extends Mock implements CmsApi {}
