// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chitchat/data/chitchat_repository.dart' as _i10;
import 'package:chitchat/data/source/local/chitchat_local_source.dart' as _i8;
import 'package:chitchat/data/source/local/database_helper.dart' as _i3;
import 'package:chitchat/data/source/remote/chitchat_remote_source.dart' as _i9;
import 'package:chitchat/di/module/database_module.dart' as _i15;
import 'package:chitchat/di/module/firebase_module.dart' as _i16;
import 'package:chitchat/ui/auth/auth_controller.dart' as _i13;
import 'package:chitchat/ui/chat/chat_room_controller.dart' as _i14;
import 'package:chitchat/ui/group/group_message_controller.dart' as _i11;
import 'package:chitchat/ui/search/search_message_controller.dart' as _i12;
import 'package:cloud_firestore/cloud_firestore.dart' as _i5;
import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:firebase_storage/firebase_storage.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i7;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final databaseModule = _$DatabaseModule();
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i3.DatabaseHelper>(() => databaseModule.databaseHelper);
    gh.lazySingleton<_i4.FirebaseAuth>(() => firebaseModule.authentication);
    gh.lazySingleton<_i5.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i6.FirebaseStorage>(() => firebaseModule.storage);
    gh.lazySingleton<_i7.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.singleton<_i8.ChitChatLocalSource>(
        _i8.ChitChatLocalSourceImpl(databaseHelper: gh<_i3.DatabaseHelper>()));
    gh.singleton<_i9.ChitChatRemoteSource>(_i9.ChitChatRemoteSourceImpl(
      firestore: gh<_i5.FirebaseFirestore>(),
      authentication: gh<_i4.FirebaseAuth>(),
      googleSignIn: gh<_i7.GoogleSignIn>(),
      storage: gh<_i6.FirebaseStorage>(),
    ));
    gh.factory<_i10.ChitChatRepository>(() => _i10.ChitChatRepositoryImpl(
          remoteSource: gh<_i9.ChitChatRemoteSource>(),
          localSource: gh<_i8.ChitChatLocalSource>(),
        ));
    gh.factory<_i11.GroupMessageController>(() =>
        _i11.GroupMessageController(repository: gh<_i10.ChitChatRepository>()));
    gh.factory<_i12.SearchMessageController>(() => _i12.SearchMessageController(
        repository: gh<_i10.ChitChatRepository>()));
    gh.factory<_i13.AuthController>(
        () => _i13.AuthController(repository: gh<_i10.ChitChatRepository>()));
    gh.factory<_i14.ChatRoomController>(() =>
        _i14.ChatRoomController(repository: gh<_i10.ChitChatRepository>()));
    return this;
  }
}

class _$DatabaseModule extends _i15.DatabaseModule {}

class _$FirebaseModule extends _i16.FirebaseModule {}
