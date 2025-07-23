import 'package:get_it/get_it.dart';
import 'application/chat/chat_cubit.dart';
import 'domain/repositories/chat_repository.dart';
import 'infrastructure/repositories/chat_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Repositories
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );

  // Blocs/Cubits
  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(getIt<ChatRepository>()),
  );
}
