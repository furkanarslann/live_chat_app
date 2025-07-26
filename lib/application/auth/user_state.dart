part of 'user_cubit.dart';

class UserState extends Equatable {
  final bool isLoading;
  final Option<Either<Failure, User>> failureOrUserOpt;

  const UserState({
    this.isLoading = false,
    this.failureOrUserOpt = const None(),
  });

  @override
  List<Object?> get props => [isLoading, failureOrUserOpt];

  UserState copyWith({
    bool? isLoading,
    Option<Either<Failure, User>>? failureOrUserOpt,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      failureOrUserOpt: failureOrUserOpt ?? this.failureOrUserOpt,
    );
  }

  Option<User> get userOpt => failureOrUserOpt.fold(
        () => none(),
        (failureOrUser) => failureOrUser.fold(
          (failure) => none(),
          (user) => some(user),
        ),
      );

  User? get user => userOpt.toNullable();
}
