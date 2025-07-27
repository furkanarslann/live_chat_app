import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/application/chat/create_chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_search_cubit.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';
import 'package:live_chat_app/application/theme/theme_cubit.dart';
import 'package:live_chat_app/domain/auth/auth_repository.dart';
import 'package:live_chat_app/domain/auth/user_repository.dart';
import 'package:live_chat_app/infrastructure/auth/auth_repository_impl.dart';
import 'package:live_chat_app/infrastructure/auth/user_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'application/chat/chat_cubit.dart';
import 'domain/chat/chat_repository.dart';
import 'infrastructure/chat/chat_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Blocs/Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(getIt<ChatRepository>()),
  );

  getIt.registerFactory<UserCubit>(
    () => UserCubit(getIt<UserRepository>()),
  );

  getIt.registerFactory<CreateChatCubit>(
    () => CreateChatCubit(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerFactory<ThemeCubit>(
    () => ThemeCubit(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerFactory<LanguageCubit>(
    () => LanguageCubit(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerFactory<ChatSearchCubit>(
    () => ChatSearchCubit(),
  );
}
