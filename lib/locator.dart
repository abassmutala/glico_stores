import 'package:get_it/get_it.dart';
import 'package:glico_stores/services/auth_service.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/services/image_picker_service.dart';
import 'package:glico_stores/services/location_service.dart';
import 'package:glico_stores/services/navigation_service.dart';
import 'package:glico_stores/services/storage_service.dart';

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
