// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppliancesTable extends Appliances
    with TableInfo<$AppliancesTable, ApplianceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppliancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, isArchived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appliances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApplianceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApplianceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApplianceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $AppliancesTable createAlias(String alias) {
    return $AppliancesTable(attachedDatabase, alias);
  }
}

class ApplianceRow extends DataClass implements Insertable<ApplianceRow> {
  final String id;
  final String name;
  final int sortOrder;
  final bool isArchived;
  const ApplianceRow({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  AppliancesCompanion toCompanion(bool nullToAbsent) {
    return AppliancesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
    );
  }

  factory ApplianceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApplianceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  ApplianceRow copyWith({
    String? id,
    String? name,
    int? sortOrder,
    bool? isArchived,
  }) => ApplianceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
  );
  ApplianceRow copyWithCompanion(AppliancesCompanion data) {
    return ApplianceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApplianceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApplianceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived);
}

class AppliancesCompanion extends UpdateCompanion<ApplianceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const AppliancesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppliancesCompanion.insert({
    required String id,
    required String name,
    required int sortOrder,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<ApplianceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppliancesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return AppliancesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppliancesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZonesTable extends Zones with TableInfo<$ZonesTable, ZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applianceIdMeta = const VerificationMeta(
    'applianceId',
  );
  @override
  late final GeneratedColumn<String> applianceId = GeneratedColumn<String>(
    'appliance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES appliances (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zones (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    applianceId,
    parentId,
    name,
    sortOrder,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('appliance_id')) {
      context.handle(
        _applianceIdMeta,
        applianceId.isAcceptableOrUnknown(
          data['appliance_id']!,
          _applianceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applianceIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, applianceId},
  ];
  @override
  ZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      applianceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appliance_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $ZonesTable createAlias(String alias) {
    return $ZonesTable(attachedDatabase, alias);
  }
}

class ZoneRow extends DataClass implements Insertable<ZoneRow> {
  final String id;
  final String applianceId;
  final String? parentId;
  final String name;
  final int sortOrder;
  final bool isArchived;
  const ZoneRow({
    required this.id,
    required this.applianceId,
    this.parentId,
    required this.name,
    required this.sortOrder,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['appliance_id'] = Variable<String>(applianceId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ZonesCompanion toCompanion(bool nullToAbsent) {
    return ZonesCompanion(
      id: Value(id),
      applianceId: Value(applianceId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
    );
  }

  factory ZoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZoneRow(
      id: serializer.fromJson<String>(json['id']),
      applianceId: serializer.fromJson<String>(json['applianceId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'applianceId': serializer.toJson<String>(applianceId),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  ZoneRow copyWith({
    String? id,
    String? applianceId,
    Value<String?> parentId = const Value.absent(),
    String? name,
    int? sortOrder,
    bool? isArchived,
  }) => ZoneRow(
    id: id ?? this.id,
    applianceId: applianceId ?? this.applianceId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
  );
  ZoneRow copyWithCompanion(ZonesCompanion data) {
    return ZoneRow(
      id: data.id.present ? data.id.value : this.id,
      applianceId: data.applianceId.present
          ? data.applianceId.value
          : this.applianceId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZoneRow(')
          ..write('id: $id, ')
          ..write('applianceId: $applianceId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, applianceId, parentId, name, sortOrder, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZoneRow &&
          other.id == this.id &&
          other.applianceId == this.applianceId &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived);
}

class ZonesCompanion extends UpdateCompanion<ZoneRow> {
  final Value<String> id;
  final Value<String> applianceId;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const ZonesCompanion({
    this.id = const Value.absent(),
    this.applianceId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZonesCompanion.insert({
    required String id,
    required String applianceId,
    this.parentId = const Value.absent(),
    required String name,
    required int sortOrder,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       applianceId = Value(applianceId),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<ZoneRow> custom({
    Expression<String>? id,
    Expression<String>? applianceId,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (applianceId != null) 'appliance_id': applianceId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZonesCompanion copyWith({
    Value<String>? id,
    Value<String>? applianceId,
    Value<String?>? parentId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return ZonesCompanion(
      id: id ?? this.id,
      applianceId: applianceId ?? this.applianceId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (applianceId.present) {
      map['appliance_id'] = Variable<String>(applianceId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonesCompanion(')
          ..write('id: $id, ')
          ..write('applianceId: $applianceId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FreezerItemsTable extends FreezerItems
    with TableInfo<$FreezerItemsTable, FreezerItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FreezerItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zones (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frozenOnMeta = const VerificationMeta(
    'frozenOn',
  );
  @override
  late final GeneratedColumn<DateTime> frozenOn = GeneratedColumn<DateTime>(
    'frozen_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _useFirstOnMeta = const VerificationMeta(
    'useFirstOn',
  );
  @override
  late final GeneratedColumn<DateTime> useFirstOn = GeneratedColumn<DateTime>(
    'use_first_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thawStateMeta = const VerificationMeta(
    'thawState',
  );
  @override
  late final GeneratedColumn<String> thawState = GeneratedColumn<String>(
    'thaw_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thawStateChangedAtMeta =
      const VerificationMeta('thawStateChangedAt');
  @override
  late final GeneratedColumn<DateTime> thawStateChangedAt =
      GeneratedColumn<DateTime>(
        'thaw_state_changed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    zoneId,
    quantity,
    unit,
    frozenOn,
    useFirstOn,
    thawState,
    notes,
    createdAt,
    updatedAt,
    thawStateChangedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'freezer_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FreezerItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('frozen_on')) {
      context.handle(
        _frozenOnMeta,
        frozenOn.isAcceptableOrUnknown(data['frozen_on']!, _frozenOnMeta),
      );
    }
    if (data.containsKey('use_first_on')) {
      context.handle(
        _useFirstOnMeta,
        useFirstOn.isAcceptableOrUnknown(
          data['use_first_on']!,
          _useFirstOnMeta,
        ),
      );
    }
    if (data.containsKey('thaw_state')) {
      context.handle(
        _thawStateMeta,
        thawState.isAcceptableOrUnknown(data['thaw_state']!, _thawStateMeta),
      );
    } else if (isInserting) {
      context.missing(_thawStateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('thaw_state_changed_at')) {
      context.handle(
        _thawStateChangedAtMeta,
        thawStateChangedAt.isAcceptableOrUnknown(
          data['thaw_state_changed_at']!,
          _thawStateChangedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thawStateChangedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FreezerItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FreezerItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      frozenOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}frozen_on'],
      ),
      useFirstOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}use_first_on'],
      ),
      thawState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thaw_state'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      thawStateChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}thaw_state_changed_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $FreezerItemsTable createAlias(String alias) {
    return $FreezerItemsTable(attachedDatabase, alias);
  }
}

class FreezerItemRow extends DataClass implements Insertable<FreezerItemRow> {
  final String id;
  final String name;
  final String category;
  final String zoneId;
  final String quantity;
  final String unit;
  final DateTime? frozenOn;
  final DateTime? useFirstOn;
  final String thawState;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime thawStateChangedAt;
  final DateTime? archivedAt;
  const FreezerItemRow({
    required this.id,
    required this.name,
    required this.category,
    required this.zoneId,
    required this.quantity,
    required this.unit,
    this.frozenOn,
    this.useFirstOn,
    required this.thawState,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.thawStateChangedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['zone_id'] = Variable<String>(zoneId);
    map['quantity'] = Variable<String>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || frozenOn != null) {
      map['frozen_on'] = Variable<DateTime>(frozenOn);
    }
    if (!nullToAbsent || useFirstOn != null) {
      map['use_first_on'] = Variable<DateTime>(useFirstOn);
    }
    map['thaw_state'] = Variable<String>(thawState);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['thaw_state_changed_at'] = Variable<DateTime>(thawStateChangedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  FreezerItemsCompanion toCompanion(bool nullToAbsent) {
    return FreezerItemsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      zoneId: Value(zoneId),
      quantity: Value(quantity),
      unit: Value(unit),
      frozenOn: frozenOn == null && nullToAbsent
          ? const Value.absent()
          : Value(frozenOn),
      useFirstOn: useFirstOn == null && nullToAbsent
          ? const Value.absent()
          : Value(useFirstOn),
      thawState: Value(thawState),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      thawStateChangedAt: Value(thawStateChangedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory FreezerItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FreezerItemRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      frozenOn: serializer.fromJson<DateTime?>(json['frozenOn']),
      useFirstOn: serializer.fromJson<DateTime?>(json['useFirstOn']),
      thawState: serializer.fromJson<String>(json['thawState']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      thawStateChangedAt: serializer.fromJson<DateTime>(
        json['thawStateChangedAt'],
      ),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'zoneId': serializer.toJson<String>(zoneId),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
      'frozenOn': serializer.toJson<DateTime?>(frozenOn),
      'useFirstOn': serializer.toJson<DateTime?>(useFirstOn),
      'thawState': serializer.toJson<String>(thawState),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'thawStateChangedAt': serializer.toJson<DateTime>(thawStateChangedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  FreezerItemRow copyWith({
    String? id,
    String? name,
    String? category,
    String? zoneId,
    String? quantity,
    String? unit,
    Value<DateTime?> frozenOn = const Value.absent(),
    Value<DateTime?> useFirstOn = const Value.absent(),
    String? thawState,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? thawStateChangedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => FreezerItemRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    zoneId: zoneId ?? this.zoneId,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    frozenOn: frozenOn.present ? frozenOn.value : this.frozenOn,
    useFirstOn: useFirstOn.present ? useFirstOn.value : this.useFirstOn,
    thawState: thawState ?? this.thawState,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    thawStateChangedAt: thawStateChangedAt ?? this.thawStateChangedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  FreezerItemRow copyWithCompanion(FreezerItemsCompanion data) {
    return FreezerItemRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      frozenOn: data.frozenOn.present ? data.frozenOn.value : this.frozenOn,
      useFirstOn: data.useFirstOn.present
          ? data.useFirstOn.value
          : this.useFirstOn,
      thawState: data.thawState.present ? data.thawState.value : this.thawState,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      thawStateChangedAt: data.thawStateChangedAt.present
          ? data.thawStateChangedAt.value
          : this.thawStateChangedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FreezerItemRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('zoneId: $zoneId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('frozenOn: $frozenOn, ')
          ..write('useFirstOn: $useFirstOn, ')
          ..write('thawState: $thawState, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('thawStateChangedAt: $thawStateChangedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    zoneId,
    quantity,
    unit,
    frozenOn,
    useFirstOn,
    thawState,
    notes,
    createdAt,
    updatedAt,
    thawStateChangedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FreezerItemRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.zoneId == this.zoneId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.frozenOn == this.frozenOn &&
          other.useFirstOn == this.useFirstOn &&
          other.thawState == this.thawState &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.thawStateChangedAt == this.thawStateChangedAt &&
          other.archivedAt == this.archivedAt);
}

class FreezerItemsCompanion extends UpdateCompanion<FreezerItemRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> zoneId;
  final Value<String> quantity;
  final Value<String> unit;
  final Value<DateTime?> frozenOn;
  final Value<DateTime?> useFirstOn;
  final Value<String> thawState;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> thawStateChangedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const FreezerItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.frozenOn = const Value.absent(),
    this.useFirstOn = const Value.absent(),
    this.thawState = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.thawStateChangedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FreezerItemsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String zoneId,
    required String quantity,
    required String unit,
    this.frozenOn = const Value.absent(),
    this.useFirstOn = const Value.absent(),
    required String thawState,
    required String notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime thawStateChangedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       zoneId = Value(zoneId),
       quantity = Value(quantity),
       unit = Value(unit),
       thawState = Value(thawState),
       notes = Value(notes),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       thawStateChangedAt = Value(thawStateChangedAt);
  static Insertable<FreezerItemRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? zoneId,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<DateTime>? frozenOn,
    Expression<DateTime>? useFirstOn,
    Expression<String>? thawState,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? thawStateChangedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (zoneId != null) 'zone_id': zoneId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (frozenOn != null) 'frozen_on': frozenOn,
      if (useFirstOn != null) 'use_first_on': useFirstOn,
      if (thawState != null) 'thaw_state': thawState,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (thawStateChangedAt != null)
        'thaw_state_changed_at': thawStateChangedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FreezerItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String>? zoneId,
    Value<String>? quantity,
    Value<String>? unit,
    Value<DateTime?>? frozenOn,
    Value<DateTime?>? useFirstOn,
    Value<String>? thawState,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? thawStateChangedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return FreezerItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      zoneId: zoneId ?? this.zoneId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      frozenOn: frozenOn ?? this.frozenOn,
      useFirstOn: useFirstOn ?? this.useFirstOn,
      thawState: thawState ?? this.thawState,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thawStateChangedAt: thawStateChangedAt ?? this.thawStateChangedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (frozenOn.present) {
      map['frozen_on'] = Variable<DateTime>(frozenOn.value);
    }
    if (useFirstOn.present) {
      map['use_first_on'] = Variable<DateTime>(useFirstOn.value);
    }
    if (thawState.present) {
      map['thaw_state'] = Variable<String>(thawState.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (thawStateChangedAt.present) {
      map['thaw_state_changed_at'] = Variable<DateTime>(
        thawStateChangedAt.value,
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FreezerItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('zoneId: $zoneId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('frozenOn: $frozenOn, ')
          ..write('useFirstOn: $useFirstOn, ')
          ..write('thawState: $thawState, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('thawStateChangedAt: $thawStateChangedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryEventsTable extends InventoryEvents
    with TableInfo<$InventoryEventsTable, InventoryEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES freezer_items (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeSummaryMeta = const VerificationMeta(
    'beforeSummary',
  );
  @override
  late final GeneratedColumn<String> beforeSummary = GeneratedColumn<String>(
    'before_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _afterSummaryMeta = const VerificationMeta(
    'afterSummary',
  );
  @override
  late final GeneratedColumn<String> afterSummary = GeneratedColumn<String>(
    'after_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    id,
    itemId,
    action,
    beforeSummary,
    afterSummary,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('before_summary')) {
      context.handle(
        _beforeSummaryMeta,
        beforeSummary.isAcceptableOrUnknown(
          data['before_summary']!,
          _beforeSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beforeSummaryMeta);
    }
    if (data.containsKey('after_summary')) {
      context.handle(
        _afterSummaryMeta,
        afterSummary.isAcceptableOrUnknown(
          data['after_summary']!,
          _afterSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_afterSummaryMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequence};
  @override
  InventoryEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryEventRow(
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      beforeSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_summary'],
      )!,
      afterSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_summary'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $InventoryEventsTable createAlias(String alias) {
    return $InventoryEventsTable(attachedDatabase, alias);
  }
}

class InventoryEventRow extends DataClass
    implements Insertable<InventoryEventRow> {
  final int sequence;
  final String id;
  final String itemId;
  final String action;
  final String beforeSummary;
  final String afterSummary;
  final DateTime occurredAt;
  const InventoryEventRow({
    required this.sequence,
    required this.id,
    required this.itemId,
    required this.action,
    required this.beforeSummary,
    required this.afterSummary,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['action'] = Variable<String>(action);
    map['before_summary'] = Variable<String>(beforeSummary);
    map['after_summary'] = Variable<String>(afterSummary);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  InventoryEventsCompanion toCompanion(bool nullToAbsent) {
    return InventoryEventsCompanion(
      sequence: Value(sequence),
      id: Value(id),
      itemId: Value(itemId),
      action: Value(action),
      beforeSummary: Value(beforeSummary),
      afterSummary: Value(afterSummary),
      occurredAt: Value(occurredAt),
    );
  }

  factory InventoryEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryEventRow(
      sequence: serializer.fromJson<int>(json['sequence']),
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      action: serializer.fromJson<String>(json['action']),
      beforeSummary: serializer.fromJson<String>(json['beforeSummary']),
      afterSummary: serializer.fromJson<String>(json['afterSummary']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'action': serializer.toJson<String>(action),
      'beforeSummary': serializer.toJson<String>(beforeSummary),
      'afterSummary': serializer.toJson<String>(afterSummary),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  InventoryEventRow copyWith({
    int? sequence,
    String? id,
    String? itemId,
    String? action,
    String? beforeSummary,
    String? afterSummary,
    DateTime? occurredAt,
  }) => InventoryEventRow(
    sequence: sequence ?? this.sequence,
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    action: action ?? this.action,
    beforeSummary: beforeSummary ?? this.beforeSummary,
    afterSummary: afterSummary ?? this.afterSummary,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  InventoryEventRow copyWithCompanion(InventoryEventsCompanion data) {
    return InventoryEventRow(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      action: data.action.present ? data.action.value : this.action,
      beforeSummary: data.beforeSummary.present
          ? data.beforeSummary.value
          : this.beforeSummary,
      afterSummary: data.afterSummary.present
          ? data.afterSummary.value
          : this.afterSummary,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryEventRow(')
          ..write('sequence: $sequence, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('action: $action, ')
          ..write('beforeSummary: $beforeSummary, ')
          ..write('afterSummary: $afterSummary, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequence,
    id,
    itemId,
    action,
    beforeSummary,
    afterSummary,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryEventRow &&
          other.sequence == this.sequence &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.action == this.action &&
          other.beforeSummary == this.beforeSummary &&
          other.afterSummary == this.afterSummary &&
          other.occurredAt == this.occurredAt);
}

class InventoryEventsCompanion extends UpdateCompanion<InventoryEventRow> {
  final Value<int> sequence;
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> action;
  final Value<String> beforeSummary;
  final Value<String> afterSummary;
  final Value<DateTime> occurredAt;
  const InventoryEventsCompanion({
    this.sequence = const Value.absent(),
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.action = const Value.absent(),
    this.beforeSummary = const Value.absent(),
    this.afterSummary = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  InventoryEventsCompanion.insert({
    this.sequence = const Value.absent(),
    required String id,
    required String itemId,
    required String action,
    required String beforeSummary,
    required String afterSummary,
    required DateTime occurredAt,
  }) : id = Value(id),
       itemId = Value(itemId),
       action = Value(action),
       beforeSummary = Value(beforeSummary),
       afterSummary = Value(afterSummary),
       occurredAt = Value(occurredAt);
  static Insertable<InventoryEventRow> custom({
    Expression<int>? sequence,
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? action,
    Expression<String>? beforeSummary,
    Expression<String>? afterSummary,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (action != null) 'action': action,
      if (beforeSummary != null) 'before_summary': beforeSummary,
      if (afterSummary != null) 'after_summary': afterSummary,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  InventoryEventsCompanion copyWith({
    Value<int>? sequence,
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? action,
    Value<String>? beforeSummary,
    Value<String>? afterSummary,
    Value<DateTime>? occurredAt,
  }) {
    return InventoryEventsCompanion(
      sequence: sequence ?? this.sequence,
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      action: action ?? this.action,
      beforeSummary: beforeSummary ?? this.beforeSummary,
      afterSummary: afterSummary ?? this.afterSummary,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (beforeSummary.present) {
      map['before_summary'] = Variable<String>(beforeSummary.value);
    }
    if (afterSummary.present) {
      map['after_summary'] = Variable<String>(afterSummary.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryEventsCompanion(')
          ..write('sequence: $sequence, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('action: $action, ')
          ..write('beforeSummary: $beforeSummary, ')
          ..write('afterSummary: $afterSummary, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES freezer_items (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyModeMeta = const VerificationMeta(
    'privacyMode',
  );
  @override
  late final GeneratedColumn<String> privacyMode = GeneratedColumn<String>(
    'privacy_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    scheduledFor,
    privacyMode,
    isEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('privacy_mode')) {
      context.handle(
        _privacyModeMeta,
        privacyMode.isAcceptableOrUnknown(
          data['privacy_mode']!,
          _privacyModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyModeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    } else if (isInserting) {
      context.missing(_isEnabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
      privacyMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_mode'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String itemId;
  final DateTime scheduledFor;
  final String privacyMode;
  final bool isEnabled;
  const ReminderRow({
    required this.id,
    required this.itemId,
    required this.scheduledFor,
    required this.privacyMode,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    map['privacy_mode'] = Variable<String>(privacyMode);
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      itemId: Value(itemId),
      scheduledFor: Value(scheduledFor),
      privacyMode: Value(privacyMode),
      isEnabled: Value(isEnabled),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      privacyMode: serializer.fromJson<String>(json['privacyMode']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'privacyMode': serializer.toJson<String>(privacyMode),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? itemId,
    DateTime? scheduledFor,
    String? privacyMode,
    bool? isEnabled,
  }) => ReminderRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    privacyMode: privacyMode ?? this.privacyMode,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      privacyMode: data.privacyMode.present
          ? data.privacyMode.value
          : this.privacyMode,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('privacyMode: $privacyMode, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, scheduledFor, privacyMode, isEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.scheduledFor == this.scheduledFor &&
          other.privacyMode == this.privacyMode &&
          other.isEnabled == this.isEnabled);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<DateTime> scheduledFor;
  final Value<String> privacyMode;
  final Value<bool> isEnabled;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.privacyMode = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String itemId,
    required DateTime scheduledFor,
    required String privacyMode,
    required bool isEnabled,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       scheduledFor = Value(scheduledFor),
       privacyMode = Value(privacyMode),
       isEnabled = Value(isEnabled);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<DateTime>? scheduledFor,
    Expression<String>? privacyMode,
    Expression<bool>? isEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (privacyMode != null) 'privacy_mode': privacyMode,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<DateTime>? scheduledFor,
    Value<String>? privacyMode,
    Value<bool>? isEnabled,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      privacyMode: privacyMode ?? this.privacyMode,
      isEnabled: isEnabled ?? this.isEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (privacyMode.present) {
      map['privacy_mode'] = Variable<String>(privacyMode.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('privacyMode: $privacyMode, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FreezerDatabase extends GeneratedDatabase {
  _$FreezerDatabase(QueryExecutor e) : super(e);
  $FreezerDatabaseManager get managers => $FreezerDatabaseManager(this);
  late final $AppliancesTable appliances = $AppliancesTable(this);
  late final $ZonesTable zones = $ZonesTable(this);
  late final $FreezerItemsTable freezerItems = $FreezerItemsTable(this);
  late final $InventoryEventsTable inventoryEvents = $InventoryEventsTable(
    this,
  );
  late final $RemindersTable reminders = $RemindersTable(this);
  late final Index zonesApplianceParentIdx = Index(
    'zones_appliance_parent_idx',
    'CREATE INDEX zones_appliance_parent_idx ON zones (appliance_id, parent_id, is_archived)',
  );
  late final Index freezerItemsZoneArchivedIdx = Index(
    'freezer_items_zone_archived_idx',
    'CREATE INDEX freezer_items_zone_archived_idx ON freezer_items (zone_id, archived_at)',
  );
  late final Index freezerItemsUseFirstIdx = Index(
    'freezer_items_use_first_idx',
    'CREATE INDEX freezer_items_use_first_idx ON freezer_items (archived_at, use_first_on)',
  );
  late final Index inventoryEventsItemTimeIdx = Index(
    'inventory_events_item_time_idx',
    'CREATE INDEX inventory_events_item_time_idx ON inventory_events (item_id, occurred_at, id)',
  );
  late final Index remindersItemEnabledIdx = Index(
    'reminders_item_enabled_idx',
    'CREATE INDEX reminders_item_enabled_idx ON reminders (item_id, is_enabled, scheduled_for)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appliances,
    zones,
    freezerItems,
    inventoryEvents,
    reminders,
    zonesApplianceParentIdx,
    freezerItemsZoneArchivedIdx,
    freezerItemsUseFirstIdx,
    inventoryEventsItemTimeIdx,
    remindersItemEnabledIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'appliances',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('zones', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'zones',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('zones', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'zones',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('freezer_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'freezer_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('inventory_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'freezer_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$AppliancesTableCreateCompanionBuilder = AppliancesCompanion Function({
  required String id,
  required String name,
  required int sortOrder,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$AppliancesTableUpdateCompanionBuilder = AppliancesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$AppliancesTableReferences
    extends BaseReferences<_$FreezerDatabase, $AppliancesTable, ApplianceRow> {
  $$AppliancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ZonesTable, List<ZoneRow>> _zonesRefsTable(
    _$FreezerDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.zones,
    aliasName: 'appliances__id__zones__appliance_id',
  );

  $$ZonesTableProcessedTableManager get zonesRefs {
    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.applianceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_zonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppliancesTableFilterComposer
    extends Composer<_$FreezerDatabase, $AppliancesTable> {
  $$AppliancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> zonesRefs(
    Expression<bool> Function($$ZonesTableFilterComposer f) f,
  ) {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.applianceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppliancesTableOrderingComposer
    extends Composer<_$FreezerDatabase, $AppliancesTable> {
  $$AppliancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppliancesTableAnnotationComposer
    extends Composer<_$FreezerDatabase, $AppliancesTable> {
  $$AppliancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> zonesRefs<T extends Object>(
    Expression<T> Function($$ZonesTableAnnotationComposer a) f,
  ) {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.applianceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppliancesTableTableManager
    extends
        RootTableManager<
          _$FreezerDatabase,
          $AppliancesTable,
          ApplianceRow,
          $$AppliancesTableFilterComposer,
          $$AppliancesTableOrderingComposer,
          $$AppliancesTableAnnotationComposer,
          $$AppliancesTableCreateCompanionBuilder,
          $$AppliancesTableUpdateCompanionBuilder,
          (ApplianceRow, $$AppliancesTableReferences),
          ApplianceRow,
          PrefetchHooks Function({bool zonesRefs})
        > {
  $$AppliancesTableTableManager(_$FreezerDatabase db, $AppliancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppliancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppliancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppliancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppliancesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int sortOrder,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppliancesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppliancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({zonesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (zonesRefs) db.zones],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (zonesRefs)
                    await $_getPrefetchedData<
                      ApplianceRow,
                      $AppliancesTable,
                      ZoneRow
                    >(
                      currentTable: table,
                      referencedTable: $$AppliancesTableReferences
                          ._zonesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AppliancesTableReferences(db, table, p0).zonesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.applianceId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AppliancesTableProcessedTableManager =
    ProcessedTableManager<
      _$FreezerDatabase,
      $AppliancesTable,
      ApplianceRow,
      $$AppliancesTableFilterComposer,
      $$AppliancesTableOrderingComposer,
      $$AppliancesTableAnnotationComposer,
      $$AppliancesTableCreateCompanionBuilder,
      $$AppliancesTableUpdateCompanionBuilder,
      (ApplianceRow, $$AppliancesTableReferences),
      ApplianceRow,
      PrefetchHooks Function({bool zonesRefs})
    >;
typedef $$ZonesTableCreateCompanionBuilder = ZonesCompanion Function({
  required String id,
  required String applianceId,
  Value<String?> parentId,
  required String name,
  required int sortOrder,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$ZonesTableUpdateCompanionBuilder = ZonesCompanion Function({
  Value<String> id,
  Value<String> applianceId,
  Value<String?> parentId,
  Value<String> name,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$ZonesTableReferences
    extends BaseReferences<_$FreezerDatabase, $ZonesTable, ZoneRow> {
  $$ZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppliancesTable _applianceIdTable(_$FreezerDatabase db) =>
      db.appliances.createAlias('zones__appliance_id__appliances__id');

  $$AppliancesTableProcessedTableManager get applianceId {
    final $_column = $_itemColumn<String>('appliance_id')!;

    final manager = $$AppliancesTableTableManager(
      $_db,
      $_db.appliances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applianceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ZonesTable _parentIdTable(_$FreezerDatabase db) =>
      db.zones.createAlias('zones__parent_id__zones__id');

  $$ZonesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FreezerItemsTable, List<FreezerItemRow>>
  _freezerItemsRefsTable(_$FreezerDatabase db) => MultiTypedResultKey.fromTable(
    db.freezerItems,
    aliasName: 'zones__id__freezer_items__zone_id',
  );

  $$FreezerItemsTableProcessedTableManager get freezerItemsRefs {
    final manager = $$FreezerItemsTableTableManager(
      $_db,
      $_db.freezerItems,
    ).filter((f) => f.zoneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_freezerItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ZonesTableFilterComposer
    extends Composer<_$FreezerDatabase, $ZonesTable> {
  $$ZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  $$AppliancesTableFilterComposer get applianceId {
    final $$AppliancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applianceId,
      referencedTable: $db.appliances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppliancesTableFilterComposer(
            $db: $db,
            $table: $db.appliances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableFilterComposer get parentId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> freezerItemsRefs(
    Expression<bool> Function($$FreezerItemsTableFilterComposer f) f,
  ) {
    final $$FreezerItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableFilterComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableOrderingComposer
    extends Composer<_$FreezerDatabase, $ZonesTable> {
  $$ZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppliancesTableOrderingComposer get applianceId {
    final $$AppliancesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applianceId,
      referencedTable: $db.appliances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppliancesTableOrderingComposer(
            $db: $db,
            $table: $db.appliances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableOrderingComposer get parentId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZonesTableAnnotationComposer
    extends Composer<_$FreezerDatabase, $ZonesTable> {
  $$ZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  $$AppliancesTableAnnotationComposer get applianceId {
    final $$AppliancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applianceId,
      referencedTable: $db.appliances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppliancesTableAnnotationComposer(
            $db: $db,
            $table: $db.appliances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableAnnotationComposer get parentId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> freezerItemsRefs<T extends Object>(
    Expression<T> Function($$FreezerItemsTableAnnotationComposer a) f,
  ) {
    final $$FreezerItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableTableManager
    extends
        RootTableManager<
          _$FreezerDatabase,
          $ZonesTable,
          ZoneRow,
          $$ZonesTableFilterComposer,
          $$ZonesTableOrderingComposer,
          $$ZonesTableAnnotationComposer,
          $$ZonesTableCreateCompanionBuilder,
          $$ZonesTableUpdateCompanionBuilder,
          (ZoneRow, $$ZonesTableReferences),
          ZoneRow,
          PrefetchHooks Function({
            bool applianceId,
            bool parentId,
            bool freezerItemsRefs,
          })
        > {
  $$ZonesTableTableManager(_$FreezerDatabase db, $ZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> applianceId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZonesCompanion(
                id: id,
                applianceId: applianceId,
                parentId: parentId,
                name: name,
                sortOrder: sortOrder,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String applianceId,
                Value<String?> parentId = const Value.absent(),
                required String name,
                required int sortOrder,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZonesCompanion.insert(
                id: id,
                applianceId: applianceId,
                parentId: parentId,
                name: name,
                sortOrder: sortOrder,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ZonesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                applianceId = false,
                parentId = false,
                freezerItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (freezerItemsRefs) db.freezerItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (applianceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.applianceId,
                            referencedTable: $$ZonesTableReferences
                                ._applianceIdTable(db),
                            referencedColumn: $$ZonesTableReferences
                                ._applianceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (parentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentId,
                            referencedTable: $$ZonesTableReferences
                                ._parentIdTable(db),
                            referencedColumn: $$ZonesTableReferences
                                ._parentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (freezerItemsRefs)
                        await $_getPrefetchedData<
                          ZoneRow,
                          $ZonesTable,
                          FreezerItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ZonesTableReferences
                              ._freezerItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ZonesTableReferences(
                                db,
                                table,
                                p0,
                              ).freezerItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.zoneId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$FreezerDatabase,
      $ZonesTable,
      ZoneRow,
      $$ZonesTableFilterComposer,
      $$ZonesTableOrderingComposer,
      $$ZonesTableAnnotationComposer,
      $$ZonesTableCreateCompanionBuilder,
      $$ZonesTableUpdateCompanionBuilder,
      (ZoneRow, $$ZonesTableReferences),
      ZoneRow,
      PrefetchHooks Function({
        bool applianceId,
        bool parentId,
        bool freezerItemsRefs,
      })
    >;
typedef $$FreezerItemsTableCreateCompanionBuilder =
    FreezerItemsCompanion Function({
      required String id,
      required String name,
      required String category,
      required String zoneId,
      required String quantity,
      required String unit,
      Value<DateTime?> frozenOn,
      Value<DateTime?> useFirstOn,
      required String thawState,
      required String notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime thawStateChangedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$FreezerItemsTableUpdateCompanionBuilder =
    FreezerItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<String> zoneId,
      Value<String> quantity,
      Value<String> unit,
      Value<DateTime?> frozenOn,
      Value<DateTime?> useFirstOn,
      Value<String> thawState,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> thawStateChangedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$FreezerItemsTableReferences
    extends
        BaseReferences<_$FreezerDatabase, $FreezerItemsTable, FreezerItemRow> {
  $$FreezerItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ZonesTable _zoneIdTable(_$FreezerDatabase db) =>
      db.zones.createAlias('freezer_items__zone_id__zones__id');

  $$ZonesTableProcessedTableManager get zoneId {
    final $_column = $_itemColumn<String>('zone_id')!;

    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InventoryEventsTable, List<InventoryEventRow>>
  _inventoryEventsRefsTable(_$FreezerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryEvents,
        aliasName: 'freezer_items__id__inventory_events__item_id',
      );

  $$InventoryEventsTableProcessedTableManager get inventoryEventsRefs {
    final manager = $$InventoryEventsTableTableManager(
      $_db,
      $_db.inventoryEvents,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$FreezerDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'freezer_items__id__reminders__item_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FreezerItemsTableFilterComposer
    extends Composer<_$FreezerDatabase, $FreezerItemsTable> {
  $$FreezerItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get frozenOn => $composableBuilder(
    column: $table.frozenOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get useFirstOn => $composableBuilder(
    column: $table.useFirstOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thawState => $composableBuilder(
    column: $table.thawState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get thawStateChangedAt => $composableBuilder(
    column: $table.thawStateChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ZonesTableFilterComposer get zoneId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> inventoryEventsRefs(
    Expression<bool> Function($$InventoryEventsTableFilterComposer f) f,
  ) {
    final $$InventoryEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryEvents,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryEventsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FreezerItemsTableOrderingComposer
    extends Composer<_$FreezerDatabase, $FreezerItemsTable> {
  $$FreezerItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get frozenOn => $composableBuilder(
    column: $table.frozenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get useFirstOn => $composableBuilder(
    column: $table.useFirstOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thawState => $composableBuilder(
    column: $table.thawState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get thawStateChangedAt => $composableBuilder(
    column: $table.thawStateChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ZonesTableOrderingComposer get zoneId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FreezerItemsTableAnnotationComposer
    extends Composer<_$FreezerDatabase, $FreezerItemsTable> {
  $$FreezerItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get frozenOn =>
      $composableBuilder(column: $table.frozenOn, builder: (column) => column);

  GeneratedColumn<DateTime> get useFirstOn => $composableBuilder(
    column: $table.useFirstOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thawState =>
      $composableBuilder(column: $table.thawState, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get thawStateChangedAt => $composableBuilder(
    column: $table.thawStateChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ZonesTableAnnotationComposer get zoneId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> inventoryEventsRefs<T extends Object>(
    Expression<T> Function($$InventoryEventsTableAnnotationComposer a) f,
  ) {
    final $$InventoryEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryEvents,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FreezerItemsTableTableManager
    extends
        RootTableManager<
          _$FreezerDatabase,
          $FreezerItemsTable,
          FreezerItemRow,
          $$FreezerItemsTableFilterComposer,
          $$FreezerItemsTableOrderingComposer,
          $$FreezerItemsTableAnnotationComposer,
          $$FreezerItemsTableCreateCompanionBuilder,
          $$FreezerItemsTableUpdateCompanionBuilder,
          (FreezerItemRow, $$FreezerItemsTableReferences),
          FreezerItemRow,
          PrefetchHooks Function({
            bool zoneId,
            bool inventoryEventsRefs,
            bool remindersRefs,
          })
        > {
  $$FreezerItemsTableTableManager(
    _$FreezerDatabase db,
    $FreezerItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FreezerItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FreezerItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FreezerItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime?> frozenOn = const Value.absent(),
                Value<DateTime?> useFirstOn = const Value.absent(),
                Value<String> thawState = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> thawStateChangedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FreezerItemsCompanion(
                id: id,
                name: name,
                category: category,
                zoneId: zoneId,
                quantity: quantity,
                unit: unit,
                frozenOn: frozenOn,
                useFirstOn: useFirstOn,
                thawState: thawState,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                thawStateChangedAt: thawStateChangedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required String zoneId,
                required String quantity,
                required String unit,
                Value<DateTime?> frozenOn = const Value.absent(),
                Value<DateTime?> useFirstOn = const Value.absent(),
                required String thawState,
                required String notes,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime thawStateChangedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FreezerItemsCompanion.insert(
                id: id,
                name: name,
                category: category,
                zoneId: zoneId,
                quantity: quantity,
                unit: unit,
                frozenOn: frozenOn,
                useFirstOn: useFirstOn,
                thawState: thawState,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                thawStateChangedAt: thawStateChangedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FreezerItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                zoneId = false,
                inventoryEventsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inventoryEventsRefs) db.inventoryEvents,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (zoneId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.zoneId,
                            referencedTable: $$FreezerItemsTableReferences
                                ._zoneIdTable(db),
                            referencedColumn: $$FreezerItemsTableReferences
                                ._zoneIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inventoryEventsRefs)
                        await $_getPrefetchedData<
                          FreezerItemRow,
                          $FreezerItemsTable,
                          InventoryEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$FreezerItemsTableReferences
                              ._inventoryEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FreezerItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          FreezerItemRow,
                          $FreezerItemsTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$FreezerItemsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FreezerItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FreezerItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$FreezerDatabase,
      $FreezerItemsTable,
      FreezerItemRow,
      $$FreezerItemsTableFilterComposer,
      $$FreezerItemsTableOrderingComposer,
      $$FreezerItemsTableAnnotationComposer,
      $$FreezerItemsTableCreateCompanionBuilder,
      $$FreezerItemsTableUpdateCompanionBuilder,
      (FreezerItemRow, $$FreezerItemsTableReferences),
      FreezerItemRow,
      PrefetchHooks Function({
        bool zoneId,
        bool inventoryEventsRefs,
        bool remindersRefs,
      })
    >;
typedef $$InventoryEventsTableCreateCompanionBuilder =
    InventoryEventsCompanion Function({
      Value<int> sequence,
      required String id,
      required String itemId,
      required String action,
      required String beforeSummary,
      required String afterSummary,
      required DateTime occurredAt,
    });
typedef $$InventoryEventsTableUpdateCompanionBuilder =
    InventoryEventsCompanion Function({
      Value<int> sequence,
      Value<String> id,
      Value<String> itemId,
      Value<String> action,
      Value<String> beforeSummary,
      Value<String> afterSummary,
      Value<DateTime> occurredAt,
    });

final class $$InventoryEventsTableReferences
    extends
        BaseReferences<
          _$FreezerDatabase,
          $InventoryEventsTable,
          InventoryEventRow
        > {
  $$InventoryEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FreezerItemsTable _itemIdTable(_$FreezerDatabase db) => db
      .freezerItems
      .createAlias('inventory_events__item_id__freezer_items__id');

  $$FreezerItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$FreezerItemsTableTableManager(
      $_db,
      $_db.freezerItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryEventsTableFilterComposer
    extends Composer<_$FreezerDatabase, $InventoryEventsTable> {
  $$InventoryEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeSummary => $composableBuilder(
    column: $table.beforeSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterSummary => $composableBuilder(
    column: $table.afterSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FreezerItemsTableFilterComposer get itemId {
    final $$FreezerItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableFilterComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryEventsTableOrderingComposer
    extends Composer<_$FreezerDatabase, $InventoryEventsTable> {
  $$InventoryEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeSummary => $composableBuilder(
    column: $table.beforeSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterSummary => $composableBuilder(
    column: $table.afterSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FreezerItemsTableOrderingComposer get itemId {
    final $$FreezerItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableOrderingComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryEventsTableAnnotationComposer
    extends Composer<_$FreezerDatabase, $InventoryEventsTable> {
  $$InventoryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get beforeSummary => $composableBuilder(
    column: $table.beforeSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterSummary => $composableBuilder(
    column: $table.afterSummary,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  $$FreezerItemsTableAnnotationComposer get itemId {
    final $$FreezerItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryEventsTableTableManager
    extends
        RootTableManager<
          _$FreezerDatabase,
          $InventoryEventsTable,
          InventoryEventRow,
          $$InventoryEventsTableFilterComposer,
          $$InventoryEventsTableOrderingComposer,
          $$InventoryEventsTableAnnotationComposer,
          $$InventoryEventsTableCreateCompanionBuilder,
          $$InventoryEventsTableUpdateCompanionBuilder,
          (InventoryEventRow, $$InventoryEventsTableReferences),
          InventoryEventRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$InventoryEventsTableTableManager(
    _$FreezerDatabase db,
    $InventoryEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> beforeSummary = const Value.absent(),
                Value<String> afterSummary = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => InventoryEventsCompanion(
                sequence: sequence,
                id: id,
                itemId: itemId,
                action: action,
                beforeSummary: beforeSummary,
                afterSummary: afterSummary,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                required String id,
                required String itemId,
                required String action,
                required String beforeSummary,
                required String afterSummary,
                required DateTime occurredAt,
              }) => InventoryEventsCompanion.insert(
                sequence: sequence,
                id: id,
                itemId: itemId,
                action: action,
                beforeSummary: beforeSummary,
                afterSummary: afterSummary,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InventoryEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$InventoryEventsTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$InventoryEventsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InventoryEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$FreezerDatabase,
      $InventoryEventsTable,
      InventoryEventRow,
      $$InventoryEventsTableFilterComposer,
      $$InventoryEventsTableOrderingComposer,
      $$InventoryEventsTableAnnotationComposer,
      $$InventoryEventsTableCreateCompanionBuilder,
      $$InventoryEventsTableUpdateCompanionBuilder,
      (InventoryEventRow, $$InventoryEventsTableReferences),
      InventoryEventRow,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String itemId,
  required DateTime scheduledFor,
  required String privacyMode,
  required bool isEnabled,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<DateTime> scheduledFor,
  Value<String> privacyMode,
  Value<bool> isEnabled,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$FreezerDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FreezerItemsTable _itemIdTable(_$FreezerDatabase db) =>
      db.freezerItems.createAlias('reminders__item_id__freezer_items__id');

  $$FreezerItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$FreezerItemsTableTableManager(
      $_db,
      $_db.freezerItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$FreezerDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyMode => $composableBuilder(
    column: $table.privacyMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  $$FreezerItemsTableFilterComposer get itemId {
    final $$FreezerItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableFilterComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$FreezerDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyMode => $composableBuilder(
    column: $table.privacyMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$FreezerItemsTableOrderingComposer get itemId {
    final $$FreezerItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableOrderingComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$FreezerDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacyMode => $composableBuilder(
    column: $table.privacyMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  $$FreezerItemsTableAnnotationComposer get itemId {
    final $$FreezerItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.freezerItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FreezerItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.freezerItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$FreezerDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$RemindersTableTableManager(_$FreezerDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
                Value<String> privacyMode = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                itemId: itemId,
                scheduledFor: scheduledFor,
                privacyMode: privacyMode,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required DateTime scheduledFor,
                required String privacyMode,
                required bool isEnabled,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                itemId: itemId,
                scheduledFor: scheduledFor,
                privacyMode: privacyMode,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$RemindersTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$FreezerDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool itemId})
    >;

class $FreezerDatabaseManager {
  final _$FreezerDatabase _db;
  $FreezerDatabaseManager(this._db);
  $$AppliancesTableTableManager get appliances =>
      $$AppliancesTableTableManager(_db, _db.appliances);
  $$ZonesTableTableManager get zones =>
      $$ZonesTableTableManager(_db, _db.zones);
  $$FreezerItemsTableTableManager get freezerItems =>
      $$FreezerItemsTableTableManager(_db, _db.freezerItems);
  $$InventoryEventsTableTableManager get inventoryEvents =>
      $$InventoryEventsTableTableManager(_db, _db.inventoryEvents);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
