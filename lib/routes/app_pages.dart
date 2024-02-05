import 'package:chitchat/ui/auth/auth_screen.dart';
import 'package:chitchat/ui/chat/chat_room_screen.dart';
import 'package:chitchat/ui/group/group_message_screen.dart';
import 'package:chitchat/ui/search/search_message_screen.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthScreen(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatRoomScreen(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchMessageScreen(),
    ),
    GetPage(
      name: AppRoutes.group,
      page: () => const GroupMessageScreen(),
    ),
  ];
}
