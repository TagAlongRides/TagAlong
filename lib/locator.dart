import 'package:get_it/get_it.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:user_repo/user_repo.dart';

/// Will provide the global variable for the [GetIt] singleton for accessing
/// registered services.

final serviceLocator = GetIt.instance;

void setUpServiceLocator() {
  serviceLocator.registerSingleton<UserRepository>(UserRepository());
}

