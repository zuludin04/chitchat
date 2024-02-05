import 'package:chitchat/data/source/local/database_helper.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  DatabaseHelper get databaseHelper => DatabaseHelper();
}
