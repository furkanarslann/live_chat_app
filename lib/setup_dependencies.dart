import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/domain/repositories/auth_repository.dart';
import 'package:live_chat_app/infrastructure/repositories/firebase_auth_repository.dart';
import 'application/chat/chat_cubit.dart';
import 'domain/repositories/chat_repository.dart';
import 'infrastructure/repositories/chat_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Repositories
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );

  // Blocs/Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(getIt<ChatRepository>()),
  );
}
