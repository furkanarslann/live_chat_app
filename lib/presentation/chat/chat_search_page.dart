import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/chat/chat_search_cubit.dart';
import 'package:live_chat_app/application/chat/chat_search_state.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'widgets/chat_search_input.dart';
import 'widgets/chat_search_empty_state.dart';
import 'widgets/chat_search_no_results_state.dart';
import 'widgets/chat_search_result_tile.dart';

class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    context.read<ChatSearchCubit>().searchQueryChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        return BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final currentUser = userState.user;
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: context.colors.background,
                title: Text(
                  context.tr.searchResults,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Column(
                children: [
                  ChatSearchInput(
                    controller: _searchController,
                    focusNode: _focusNode,
                  ),
                  Expanded(
                    child: BlocBuilder<ChatSearchCubit, ChatSearchState>(
                      builder: (context, searchState) {
                        if (searchState.searchQuery.isEmpty) {
                          return const ChatSearchEmptyState();
                        }

                        if (searchState.isSearching) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final results =
                            context.read<ChatSearchCubit>().performSearch(
                                  searchState.searchQuery,
                                  chatState,
                                  currentUser,
                                );

                        if (results.isEmpty) {
                          return ChatSearchNoResultsState(
                            query: searchState.searchQuery,
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final result = results[index];
                            return ChatSearchResultTile(
                              result: result,
                              currentUser: currentUser,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
