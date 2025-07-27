import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/domain/models/chat_message.dart';
import 'chat_search_state.dart';

class ChatSearchCubit extends Cubit<ChatSearchState> {
  ChatSearchCubit() : super(const ChatSearchState());

  void initialize(List<ChatMessage> allMessages) {
    emit(state.copyWith(allMessages: allMessages));
  }

  void searchQueryChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
