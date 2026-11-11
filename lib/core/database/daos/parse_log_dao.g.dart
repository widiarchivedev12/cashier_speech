// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parse_log_dao.dart';

// ignore_for_file: type=lint
mixin _$ParseLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $ParseLogsTable get parseLogs => attachedDatabase.parseLogs;
  ParseLogDaoManager get managers => ParseLogDaoManager(this);
}

class ParseLogDaoManager {
  final _$ParseLogDaoMixin _db;
  ParseLogDaoManager(this._db);
  $$ParseLogsTableTableManager get parseLogs =>
      $$ParseLogsTableTableManager(_db.attachedDatabase, _db.parseLogs);
}
