import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/user.dart';

class CreateChatState extends Equatable {
  final bool isLoading;
  final String searchQuery;
  final Option<Either<Failure, List<User>>> failureOrUsersOpt;
  final Option<Either<Failure, Unit>> failureOrSuccessOpt;

  const CreateChatState({
    this.isLoading = false,
    this.searchQuery = '',
    this.failureOrUsersOpt = const None(),
    this.failureOrSuccessOpt = const None(),
  });

  List<User> get usersOrEmpty => failureOrUsersOpt.fold(
        () => [],
        (failureOrUsers) => failureOrUsers.fold(
          (failure) => [],
          (users) => users,
        ),
      );

  List<User> get filteredUsers {
    final query = searchQuery.toLowerCase();
    if (query.isEmpty) return usersOrEmpty;

    return usersOrEmpty
        .where(
          (user) =>
              user.email.toLowerCase().contains(query) ||
              user.firstName.toLowerCase().contains(query) ||
              user.lastName.toLowerCase().contains(query) ||
              user.fullName.toLowerCase().contains(query),
        )
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  CreateChatState copyWith({
    bool? isLoading,
    String? searchQuery,
    Option<Either<Failure, List<User>>>? failureOrUsersOpt,
    Option<Either<Failure, Unit>>? failureOrSuccessOpt,
  }) {
    return CreateChatState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      failureOrUsersOpt: failureOrUsersOpt ?? this.failureOrUsersOpt,
      failureOrSuccessOpt: failureOrSuccessOpt ?? this.failureOrSuccessOpt,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        searchQuery,
        failureOrUsersOpt,
        failureOrSuccessOpt,
      ];
} 