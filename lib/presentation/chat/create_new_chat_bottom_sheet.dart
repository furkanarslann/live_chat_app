import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat_app/application/chat/create_chat_cubit.dart';
import 'package:live_chat_app/application/chat/create_chat_state.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/presentation/core/widgets/scrollable_bottom_sheet.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/router/app_router.dart';
import 'widgets/chat_user_tile.dart';

class CreateNewChatBottomSheet extends StatefulWidget {
  const CreateNewChatBottomSheet({super.key});

  @override
  State<CreateNewChatBottomSheet> createState() =>
      _CreateNewChatBottomSheetState();
}

class _CreateNewChatBottomSheetState extends State<CreateNewChatBottomSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CreateChatCubit>().searchQueryChanged(_searchController.text);
  }

  Future<void> _onUserTap(User user) async {
    final failureOrConversation =
        await context.read<CreateChatCubit>().createChat(user);

    if (!mounted) return;

    failureOrConversation.fold(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.errorOccured),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (conversation) {
        context.pop(); // Close the bottom sheet
        // Navigate to chat page - conversation will be created when first message is sent
        context.push(AppRouter.chat, extra: conversation);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateChatCubit, CreateChatState>(
      listenWhen: (p, c) => p.failureOrSuccessOpt != c.failureOrSuccessOpt,
      listener: (context, state) {
        state.failureOrSuccessOpt.fold(
          () => null,
          (failureOrSuccess) => failureOrSuccess.fold(
            (failure) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr.errorOccured),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
            (_) => null,
          ),
        );
      },
      child: ScrollableBottomSheet(
        title: context.tr.startNewChat,
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.tr.searchByNameOrEmail,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CreateChatCubit, CreateChatState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return state.failureOrUsersOpt.fold(
                    () => const Center(child: CircularProgressIndicator()),
                    (failureOrUsers) => failureOrUsers.fold(
                      (failure) => Center(
                        child: Text(
                          context.tr.errorLoadingUsers(failure.toString()),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      (_) {
                        final filteredUsers = state.filteredUsers;

                        if (state.usersOrEmpty.isEmpty) {
                          return Center(
                            child: Text(context.tr.noOtherUsers),
                          );
                        }

                        if (filteredUsers.isEmpty) {
                          return Center(
                            child: Text(context.tr.noUsersMatchSearch),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return ChatUserTile(
                              user: user,
                              onTap: () => _onUserTap(user),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
