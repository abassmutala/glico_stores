import 'package:get_it/get_it.dart';
import 'package:trilo/services/auth_service.dart';

import 'services/database_service.dart';
import 'services/image_picker_service.dart';
import 'services/location_service.dart';
import 'services/navigation_service.dart';
import 'services/storage_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => ImagePickerService());
  locator.registerLazySingleton(() => StorageService());
  // locator.registerLazySingleton(() => ImageSelector());
  // locator.registerLazySingleton(() => PushNotificationService());
}
