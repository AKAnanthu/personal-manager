// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShoppingListsTable extends ShoppingLists
    with TableInfo<$ShoppingListsTable, ShoppingListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ShoppingListStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ShoppingListStatus>($ShoppingListsTable.$converterstatus);
  static const VerificationMeta _copiedFromIdMeta = const VerificationMeta(
    'copiedFromId',
  );
  @override
  late final GeneratedColumn<String> copiedFromId = GeneratedColumn<String>(
    'copied_from_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> purchasedOn =
      GeneratedColumn<String>(
        'purchased_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ShoppingListsTable.$converterpurchasedOnn);
  static const VerificationMeta _totalPaiseMeta = const VerificationMeta(
    'totalPaise',
  );
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
    'total_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<PaymentMethod?>($ShoppingListsTable.$converterpaymentMethodn);
  static const VerificationMeta _receiptKeyMeta = const VerificationMeta(
    'receiptKey',
  );
  @override
  late final GeneratedColumn<String> receiptKey = GeneratedColumn<String>(
    'receipt_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptNameMeta = const VerificationMeta(
    'receiptName',
  );
  @override
  late final GeneratedColumn<String> receiptName = GeneratedColumn<String>(
    'receipt_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SupportedFileType?, String>
  receiptType =
      GeneratedColumn<String>(
        'receipt_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SupportedFileType?>(
        $ShoppingListsTable.$converterreceiptTypen,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    status,
    copiedFromId,
    startedAt,
    pausedAt,
    purchasedOn,
    totalPaise,
    store,
    paymentMethod,
    receiptKey,
    receiptName,
    receiptType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('copied_from_id')) {
      context.handle(
        _copiedFromIdMeta,
        copiedFromId.isAcceptableOrUnknown(
          data['copied_from_id']!,
          _copiedFromIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('total_paise')) {
      context.handle(
        _totalPaiseMeta,
        totalPaise.isAcceptableOrUnknown(data['total_paise']!, _totalPaiseMeta),
      );
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    }
    if (data.containsKey('receipt_key')) {
      context.handle(
        _receiptKeyMeta,
        receiptKey.isAcceptableOrUnknown(data['receipt_key']!, _receiptKeyMeta),
      );
    }
    if (data.containsKey('receipt_name')) {
      context.handle(
        _receiptNameMeta,
        receiptName.isAcceptableOrUnknown(
          data['receipt_name']!,
          _receiptNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: $ShoppingListsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      copiedFromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}copied_from_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      purchasedOn: $ShoppingListsTable.$converterpurchasedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}purchased_on'],
        ),
      ),
      totalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_paise'],
      ),
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      )!,
      paymentMethod: $ShoppingListsTable.$converterpaymentMethodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        ),
      ),
      receiptKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_key'],
      ),
      receiptName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_name'],
      ),
      receiptType: $ShoppingListsTable.$converterreceiptTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}receipt_type'],
        ),
      ),
    );
  }

  @override
  $ShoppingListsTable createAlias(String alias) {
    return $ShoppingListsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ShoppingListStatus, String, String>
  $converterstatus = const EnumNameConverter<ShoppingListStatus>(
    ShoppingListStatus.values,
  );
  static TypeConverter<DateTime, String> $converterpurchasedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterpurchasedOnn =
      NullAwareTypeConverter.wrap($converterpurchasedOn);
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static JsonTypeConverter2<PaymentMethod?, String?, String?>
  $converterpaymentMethodn = JsonTypeConverter2.asNullable(
    $converterpaymentMethod,
  );
  static JsonTypeConverter2<SupportedFileType, String, String>
  $converterreceiptType = const EnumNameConverter<SupportedFileType>(
    SupportedFileType.values,
  );
  static JsonTypeConverter2<SupportedFileType?, String?, String?>
  $converterreceiptTypen = JsonTypeConverter2.asNullable($converterreceiptType);
}

class ShoppingListRow extends DataClass implements Insertable<ShoppingListRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final ShoppingListStatus status;
  final String? copiedFromId;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? purchasedOn;

  /// Integer paise (INR); never a double.
  final int? totalPaise;
  final String store;
  final PaymentMethod? paymentMethod;
  final String? receiptKey;
  final String? receiptName;
  final SupportedFileType? receiptType;
  const ShoppingListRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.status,
    this.copiedFromId,
    this.startedAt,
    this.pausedAt,
    this.purchasedOn,
    this.totalPaise,
    required this.store,
    this.paymentMethod,
    this.receiptKey,
    this.receiptName,
    this.receiptType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    {
      map['status'] = Variable<String>(
        $ShoppingListsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || copiedFromId != null) {
      map['copied_from_id'] = Variable<String>(copiedFromId);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || purchasedOn != null) {
      map['purchased_on'] = Variable<String>(
        $ShoppingListsTable.$converterpurchasedOnn.toSql(purchasedOn),
      );
    }
    if (!nullToAbsent || totalPaise != null) {
      map['total_paise'] = Variable<int>(totalPaise);
    }
    map['store'] = Variable<String>(store);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(
        $ShoppingListsTable.$converterpaymentMethodn.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || receiptKey != null) {
      map['receipt_key'] = Variable<String>(receiptKey);
    }
    if (!nullToAbsent || receiptName != null) {
      map['receipt_name'] = Variable<String>(receiptName);
    }
    if (!nullToAbsent || receiptType != null) {
      map['receipt_type'] = Variable<String>(
        $ShoppingListsTable.$converterreceiptTypen.toSql(receiptType),
      );
    }
    return map;
  }

  ShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      status: Value(status),
      copiedFromId: copiedFromId == null && nullToAbsent
          ? const Value.absent()
          : Value(copiedFromId),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      purchasedOn: purchasedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasedOn),
      totalPaise: totalPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPaise),
      store: Value(store),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      receiptKey: receiptKey == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptKey),
      receiptName: receiptName == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptName),
      receiptType: receiptType == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptType),
    );
  }

  factory ShoppingListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      status: $ShoppingListsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      copiedFromId: serializer.fromJson<String?>(json['copiedFromId']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      purchasedOn: serializer.fromJson<DateTime?>(json['purchasedOn']),
      totalPaise: serializer.fromJson<int?>(json['totalPaise']),
      store: serializer.fromJson<String>(json['store']),
      paymentMethod: $ShoppingListsTable.$converterpaymentMethodn.fromJson(
        serializer.fromJson<String?>(json['paymentMethod']),
      ),
      receiptKey: serializer.fromJson<String?>(json['receiptKey']),
      receiptName: serializer.fromJson<String?>(json['receiptName']),
      receiptType: $ShoppingListsTable.$converterreceiptTypen.fromJson(
        serializer.fromJson<String?>(json['receiptType']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(
        $ShoppingListsTable.$converterstatus.toJson(status),
      ),
      'copiedFromId': serializer.toJson<String?>(copiedFromId),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'purchasedOn': serializer.toJson<DateTime?>(purchasedOn),
      'totalPaise': serializer.toJson<int?>(totalPaise),
      'store': serializer.toJson<String>(store),
      'paymentMethod': serializer.toJson<String?>(
        $ShoppingListsTable.$converterpaymentMethodn.toJson(paymentMethod),
      ),
      'receiptKey': serializer.toJson<String?>(receiptKey),
      'receiptName': serializer.toJson<String?>(receiptName),
      'receiptType': serializer.toJson<String?>(
        $ShoppingListsTable.$converterreceiptTypen.toJson(receiptType),
      ),
    };
  }

  ShoppingListRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    ShoppingListStatus? status,
    Value<String?> copiedFromId = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> pausedAt = const Value.absent(),
    Value<DateTime?> purchasedOn = const Value.absent(),
    Value<int?> totalPaise = const Value.absent(),
    String? store,
    Value<PaymentMethod?> paymentMethod = const Value.absent(),
    Value<String?> receiptKey = const Value.absent(),
    Value<String?> receiptName = const Value.absent(),
    Value<SupportedFileType?> receiptType = const Value.absent(),
  }) => ShoppingListRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    status: status ?? this.status,
    copiedFromId: copiedFromId.present ? copiedFromId.value : this.copiedFromId,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    purchasedOn: purchasedOn.present ? purchasedOn.value : this.purchasedOn,
    totalPaise: totalPaise.present ? totalPaise.value : this.totalPaise,
    store: store ?? this.store,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    receiptKey: receiptKey.present ? receiptKey.value : this.receiptKey,
    receiptName: receiptName.present ? receiptName.value : this.receiptName,
    receiptType: receiptType.present ? receiptType.value : this.receiptType,
  );
  ShoppingListRow copyWithCompanion(ShoppingListsCompanion data) {
    return ShoppingListRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      copiedFromId: data.copiedFromId.present
          ? data.copiedFromId.value
          : this.copiedFromId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      purchasedOn: data.purchasedOn.present
          ? data.purchasedOn.value
          : this.purchasedOn,
      totalPaise: data.totalPaise.present
          ? data.totalPaise.value
          : this.totalPaise,
      store: data.store.present ? data.store.value : this.store,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      receiptKey: data.receiptKey.present
          ? data.receiptKey.value
          : this.receiptKey,
      receiptName: data.receiptName.present
          ? data.receiptName.value
          : this.receiptName,
      receiptType: data.receiptType.present
          ? data.receiptType.value
          : this.receiptType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('copiedFromId: $copiedFromId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('purchasedOn: $purchasedOn, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('store: $store, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('receiptKey: $receiptKey, ')
          ..write('receiptName: $receiptName, ')
          ..write('receiptType: $receiptType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    name,
    status,
    copiedFromId,
    startedAt,
    pausedAt,
    purchasedOn,
    totalPaise,
    store,
    paymentMethod,
    receiptKey,
    receiptName,
    receiptType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.status == this.status &&
          other.copiedFromId == this.copiedFromId &&
          other.startedAt == this.startedAt &&
          other.pausedAt == this.pausedAt &&
          other.purchasedOn == this.purchasedOn &&
          other.totalPaise == this.totalPaise &&
          other.store == this.store &&
          other.paymentMethod == this.paymentMethod &&
          other.receiptKey == this.receiptKey &&
          other.receiptName == this.receiptName &&
          other.receiptType == this.receiptType);
}

class ShoppingListsCompanion extends UpdateCompanion<ShoppingListRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<ShoppingListStatus> status;
  final Value<String?> copiedFromId;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> purchasedOn;
  final Value<int?> totalPaise;
  final Value<String> store;
  final Value<PaymentMethod?> paymentMethod;
  final Value<String?> receiptKey;
  final Value<String?> receiptName;
  final Value<SupportedFileType?> receiptType;
  final Value<int> rowid;
  const ShoppingListsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.copiedFromId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.purchasedOn = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.store = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.receiptKey = const Value.absent(),
    this.receiptName = const Value.absent(),
    this.receiptType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String name,
    required ShoppingListStatus status,
    this.copiedFromId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.purchasedOn = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.store = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.receiptKey = const Value.absent(),
    this.receiptName = const Value.absent(),
    this.receiptType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       status = Value(status);
  static Insertable<ShoppingListRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? copiedFromId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? pausedAt,
    Expression<String>? purchasedOn,
    Expression<int>? totalPaise,
    Expression<String>? store,
    Expression<String>? paymentMethod,
    Expression<String>? receiptKey,
    Expression<String>? receiptName,
    Expression<String>? receiptType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (copiedFromId != null) 'copied_from_id': copiedFromId,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (purchasedOn != null) 'purchased_on': purchasedOn,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (store != null) 'store': store,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (receiptKey != null) 'receipt_key': receiptKey,
      if (receiptName != null) 'receipt_name': receiptName,
      if (receiptType != null) 'receipt_type': receiptType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<ShoppingListStatus>? status,
    Value<String?>? copiedFromId,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? pausedAt,
    Value<DateTime?>? purchasedOn,
    Value<int?>? totalPaise,
    Value<String>? store,
    Value<PaymentMethod?>? paymentMethod,
    Value<String?>? receiptKey,
    Value<String?>? receiptName,
    Value<SupportedFileType?>? receiptType,
    Value<int>? rowid,
  }) {
    return ShoppingListsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      status: status ?? this.status,
      copiedFromId: copiedFromId ?? this.copiedFromId,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      purchasedOn: purchasedOn ?? this.purchasedOn,
      totalPaise: totalPaise ?? this.totalPaise,
      store: store ?? this.store,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptKey: receiptKey ?? this.receiptKey,
      receiptName: receiptName ?? this.receiptName,
      receiptType: receiptType ?? this.receiptType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ShoppingListsTable.$converterstatus.toSql(status.value),
      );
    }
    if (copiedFromId.present) {
      map['copied_from_id'] = Variable<String>(copiedFromId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (purchasedOn.present) {
      map['purchased_on'] = Variable<String>(
        $ShoppingListsTable.$converterpurchasedOnn.toSql(purchasedOn.value),
      );
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $ShoppingListsTable.$converterpaymentMethodn.toSql(paymentMethod.value),
      );
    }
    if (receiptKey.present) {
      map['receipt_key'] = Variable<String>(receiptKey.value);
    }
    if (receiptName.present) {
      map['receipt_name'] = Variable<String>(receiptName.value);
    }
    if (receiptType.present) {
      map['receipt_type'] = Variable<String>(
        $ShoppingListsTable.$converterreceiptTypen.toSql(receiptType.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('copiedFromId: $copiedFromId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('purchasedOn: $purchasedOn, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('store: $store, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('receiptKey: $receiptKey, ')
          ..write('receiptName: $receiptName, ')
          ..write('receiptType: $receiptType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTable extends ShoppingItems
    with TableInfo<$ShoppingItemsTable, ShoppingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_lists (id) ON DELETE CASCADE',
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPurchasedMeta = const VerificationMeta(
    'isPurchased',
  );
  @override
  late final GeneratedColumn<bool> isPurchased = GeneratedColumn<bool>(
    'is_purchased',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_purchased" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    listId,
    name,
    quantity,
    unit,
    isPurchased,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('is_purchased')) {
      context.handle(
        _isPurchasedMeta,
        isPurchased.isAcceptableOrUnknown(
          data['is_purchased']!,
          _isPurchasedMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      isPurchased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_purchased'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ShoppingItemsTable createAlias(String alias) {
    return $ShoppingItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItemRow extends DataClass implements Insertable<ShoppingItemRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String listId;
  final String name;
  final String quantity;
  final String unit;
  final bool isPurchased;
  final int position;
  const ShoppingItemRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['list_id'] = Variable<String>(listId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<String>(quantity);
    map['unit'] = Variable<String>(unit);
    map['is_purchased'] = Variable<bool>(isPurchased);
    map['position'] = Variable<int>(position);
    return map;
  }

  ShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      listId: Value(listId),
      name: Value(name),
      quantity: Value(quantity),
      unit: Value(unit),
      isPurchased: Value(isPurchased),
      position: Value(position),
    );
  }

  factory ShoppingItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItemRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      listId: serializer.fromJson<String>(json['listId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      isPurchased: serializer.fromJson<bool>(json['isPurchased']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'listId': serializer.toJson<String>(listId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
      'isPurchased': serializer.toJson<bool>(isPurchased),
      'position': serializer.toJson<int>(position),
    };
  }

  ShoppingItemRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? listId,
    String? name,
    String? quantity,
    String? unit,
    bool? isPurchased,
    int? position,
  }) => ShoppingItemRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    listId: listId ?? this.listId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    isPurchased: isPurchased ?? this.isPurchased,
    position: position ?? this.position,
  );
  ShoppingItemRow copyWithCompanion(ShoppingItemsCompanion data) {
    return ShoppingItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      listId: data.listId.present ? data.listId.value : this.listId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      isPurchased: data.isPurchased.present
          ? data.isPurchased.value
          : this.isPurchased,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    listId,
    name,
    quantity,
    unit,
    isPurchased,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.listId == this.listId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.isPurchased == this.isPurchased &&
          other.position == this.position);
}

class ShoppingItemsCompanion extends UpdateCompanion<ShoppingItemRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> listId;
  final Value<String> name;
  final Value<String> quantity;
  final Value<String> unit;
  final Value<bool> isPurchased;
  final Value<int> position;
  final Value<int> rowid;
  const ShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.listId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.isPurchased = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingItemsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String listId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.isPurchased = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       listId = Value(listId),
       name = Value(name),
       position = Value(position);
  static Insertable<ShoppingItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? listId,
    Expression<String>? name,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<bool>? isPurchased,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (listId != null) 'list_id': listId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (isPurchased != null) 'is_purchased': isPurchased,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? listId,
    Value<String>? name,
    Value<String>? quantity,
    Value<String>? unit,
    Value<bool>? isPurchased,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return ShoppingItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isPurchased.present) {
      map['is_purchased'] = Variable<bool>(isPurchased.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DocumentCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DocumentCategory>($DocumentsTable.$convertercategory);
  static const VerificationMeta _fileKeyMeta = const VerificationMeta(
    'fileKey',
  );
  @override
  late final GeneratedColumn<String> fileKey = GeneratedColumn<String>(
    'file_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SupportedFileType, String>
  fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SupportedFileType>($DocumentsTable.$converterfileType);
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> expiryDate =
      GeneratedColumn<String>(
        'expiry_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($DocumentsTable.$converterexpiryDaten);
  static const VerificationMeta _expiryReminderMeta = const VerificationMeta(
    'expiryReminder',
  );
  @override
  late final GeneratedColumn<bool> expiryReminder = GeneratedColumn<bool>(
    'expiry_reminder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("expiry_reminder" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DriveStatus, String> driveStatus =
      GeneratedColumn<String>(
        'drive_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(DriveStatus.notUploaded.name),
      ).withConverter<DriveStatus>($DocumentsTable.$converterdriveStatus);
  static const VerificationMeta _driveFileIdMeta = const VerificationMeta(
    'driveFileId',
  );
  @override
  late final GeneratedColumn<String> driveFileId = GeneratedColumn<String>(
    'drive_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    title,
    description,
    category,
    fileKey,
    originalName,
    fileType,
    sizeBytes,
    expiryDate,
    expiryReminder,
    isFavourite,
    driveStatus,
    driveFileId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('file_key')) {
      context.handle(
        _fileKeyMeta,
        fileKey.isAcceptableOrUnknown(data['file_key']!, _fileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fileKeyMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('expiry_reminder')) {
      context.handle(
        _expiryReminderMeta,
        expiryReminder.isAcceptableOrUnknown(
          data['expiry_reminder']!,
          _expiryReminderMeta,
        ),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('drive_file_id')) {
      context.handle(
        _driveFileIdMeta,
        driveFileId.isAcceptableOrUnknown(
          data['drive_file_id']!,
          _driveFileIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: $DocumentsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      fileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_key'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      fileType: $DocumentsTable.$converterfileType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}file_type'],
        )!,
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      expiryDate: $DocumentsTable.$converterexpiryDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expiry_date'],
        ),
      ),
      expiryReminder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}expiry_reminder'],
      )!,
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      driveStatus: $DocumentsTable.$converterdriveStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}drive_status'],
        )!,
      ),
      driveFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_file_id'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DocumentCategory, String, String>
  $convertercategory = const EnumNameConverter<DocumentCategory>(
    DocumentCategory.values,
  );
  static JsonTypeConverter2<SupportedFileType, String, String>
  $converterfileType = const EnumNameConverter<SupportedFileType>(
    SupportedFileType.values,
  );
  static TypeConverter<DateTime, String> $converterexpiryDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterexpiryDaten =
      NullAwareTypeConverter.wrap($converterexpiryDate);
  static JsonTypeConverter2<DriveStatus, String, String> $converterdriveStatus =
      const EnumNameConverter<DriveStatus>(DriveStatus.values);
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String description;
  final DocumentCategory category;

  /// Key in the app's FileStore (never the original file name).
  final String fileKey;
  final String originalName;
  final SupportedFileType fileType;
  final int sizeBytes;
  final DateTime? expiryDate;
  final bool expiryReminder;
  final bool isFavourite;
  final DriveStatus driveStatus;

  /// Drive file id once uploaded (Drive milestone).
  final String? driveFileId;
  const DocumentRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.description,
    required this.category,
    required this.fileKey,
    required this.originalName,
    required this.fileType,
    required this.sizeBytes,
    this.expiryDate,
    required this.expiryReminder,
    required this.isFavourite,
    required this.driveStatus,
    this.driveFileId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['category'] = Variable<String>(
        $DocumentsTable.$convertercategory.toSql(category),
      );
    }
    map['file_key'] = Variable<String>(fileKey);
    map['original_name'] = Variable<String>(originalName);
    {
      map['file_type'] = Variable<String>(
        $DocumentsTable.$converterfileType.toSql(fileType),
      );
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<String>(
        $DocumentsTable.$converterexpiryDaten.toSql(expiryDate),
      );
    }
    map['expiry_reminder'] = Variable<bool>(expiryReminder);
    map['is_favourite'] = Variable<bool>(isFavourite);
    {
      map['drive_status'] = Variable<String>(
        $DocumentsTable.$converterdriveStatus.toSql(driveStatus),
      );
    }
    if (!nullToAbsent || driveFileId != null) {
      map['drive_file_id'] = Variable<String>(driveFileId);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      description: Value(description),
      category: Value(category),
      fileKey: Value(fileKey),
      originalName: Value(originalName),
      fileType: Value(fileType),
      sizeBytes: Value(sizeBytes),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      expiryReminder: Value(expiryReminder),
      isFavourite: Value(isFavourite),
      driveStatus: Value(driveStatus),
      driveFileId: driveFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(driveFileId),
    );
  }

  factory DocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      category: $DocumentsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      fileKey: serializer.fromJson<String>(json['fileKey']),
      originalName: serializer.fromJson<String>(json['originalName']),
      fileType: $DocumentsTable.$converterfileType.fromJson(
        serializer.fromJson<String>(json['fileType']),
      ),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      expiryReminder: serializer.fromJson<bool>(json['expiryReminder']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      driveStatus: $DocumentsTable.$converterdriveStatus.fromJson(
        serializer.fromJson<String>(json['driveStatus']),
      ),
      driveFileId: serializer.fromJson<String?>(json['driveFileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(
        $DocumentsTable.$convertercategory.toJson(category),
      ),
      'fileKey': serializer.toJson<String>(fileKey),
      'originalName': serializer.toJson<String>(originalName),
      'fileType': serializer.toJson<String>(
        $DocumentsTable.$converterfileType.toJson(fileType),
      ),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'expiryReminder': serializer.toJson<bool>(expiryReminder),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'driveStatus': serializer.toJson<String>(
        $DocumentsTable.$converterdriveStatus.toJson(driveStatus),
      ),
      'driveFileId': serializer.toJson<String?>(driveFileId),
    };
  }

  DocumentRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    DocumentCategory? category,
    String? fileKey,
    String? originalName,
    SupportedFileType? fileType,
    int? sizeBytes,
    Value<DateTime?> expiryDate = const Value.absent(),
    bool? expiryReminder,
    bool? isFavourite,
    DriveStatus? driveStatus,
    Value<String?> driveFileId = const Value.absent(),
  }) => DocumentRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    fileKey: fileKey ?? this.fileKey,
    originalName: originalName ?? this.originalName,
    fileType: fileType ?? this.fileType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    expiryReminder: expiryReminder ?? this.expiryReminder,
    isFavourite: isFavourite ?? this.isFavourite,
    driveStatus: driveStatus ?? this.driveStatus,
    driveFileId: driveFileId.present ? driveFileId.value : this.driveFileId,
  );
  DocumentRow copyWithCompanion(DocumentsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      fileKey: data.fileKey.present ? data.fileKey.value : this.fileKey,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      expiryReminder: data.expiryReminder.present
          ? data.expiryReminder.value
          : this.expiryReminder,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      driveStatus: data.driveStatus.present
          ? data.driveStatus.value
          : this.driveStatus,
      driveFileId: data.driveFileId.present
          ? data.driveFileId.value
          : this.driveFileId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('fileKey: $fileKey, ')
          ..write('originalName: $originalName, ')
          ..write('fileType: $fileType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('expiryReminder: $expiryReminder, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('driveStatus: $driveStatus, ')
          ..write('driveFileId: $driveFileId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    title,
    description,
    category,
    fileKey,
    originalName,
    fileType,
    sizeBytes,
    expiryDate,
    expiryReminder,
    isFavourite,
    driveStatus,
    driveFileId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.fileKey == this.fileKey &&
          other.originalName == this.originalName &&
          other.fileType == this.fileType &&
          other.sizeBytes == this.sizeBytes &&
          other.expiryDate == this.expiryDate &&
          other.expiryReminder == this.expiryReminder &&
          other.isFavourite == this.isFavourite &&
          other.driveStatus == this.driveStatus &&
          other.driveFileId == this.driveFileId);
}

class DocumentsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String> description;
  final Value<DocumentCategory> category;
  final Value<String> fileKey;
  final Value<String> originalName;
  final Value<SupportedFileType> fileType;
  final Value<int> sizeBytes;
  final Value<DateTime?> expiryDate;
  final Value<bool> expiryReminder;
  final Value<bool> isFavourite;
  final Value<DriveStatus> driveStatus;
  final Value<String?> driveFileId;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.fileKey = const Value.absent(),
    this.originalName = const Value.absent(),
    this.fileType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.expiryReminder = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.driveStatus = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String title,
    this.description = const Value.absent(),
    required DocumentCategory category,
    required String fileKey,
    required String originalName,
    required SupportedFileType fileType,
    required int sizeBytes,
    this.expiryDate = const Value.absent(),
    this.expiryReminder = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.driveStatus = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       category = Value(category),
       fileKey = Value(fileKey),
       originalName = Value(originalName),
       fileType = Value(fileType),
       sizeBytes = Value(sizeBytes);
  static Insertable<DocumentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? fileKey,
    Expression<String>? originalName,
    Expression<String>? fileType,
    Expression<int>? sizeBytes,
    Expression<String>? expiryDate,
    Expression<bool>? expiryReminder,
    Expression<bool>? isFavourite,
    Expression<String>? driveStatus,
    Expression<String>? driveFileId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (fileKey != null) 'file_key': fileKey,
      if (originalName != null) 'original_name': originalName,
      if (fileType != null) 'file_type': fileType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (expiryReminder != null) 'expiry_reminder': expiryReminder,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (driveStatus != null) 'drive_status': driveStatus,
      if (driveFileId != null) 'drive_file_id': driveFileId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? title,
    Value<String>? description,
    Value<DocumentCategory>? category,
    Value<String>? fileKey,
    Value<String>? originalName,
    Value<SupportedFileType>? fileType,
    Value<int>? sizeBytes,
    Value<DateTime?>? expiryDate,
    Value<bool>? expiryReminder,
    Value<bool>? isFavourite,
    Value<DriveStatus>? driveStatus,
    Value<String?>? driveFileId,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      fileKey: fileKey ?? this.fileKey,
      originalName: originalName ?? this.originalName,
      fileType: fileType ?? this.fileType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      expiryDate: expiryDate ?? this.expiryDate,
      expiryReminder: expiryReminder ?? this.expiryReminder,
      isFavourite: isFavourite ?? this.isFavourite,
      driveStatus: driveStatus ?? this.driveStatus,
      driveFileId: driveFileId ?? this.driveFileId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $DocumentsTable.$convertercategory.toSql(category.value),
      );
    }
    if (fileKey.present) {
      map['file_key'] = Variable<String>(fileKey.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(
        $DocumentsTable.$converterfileType.toSql(fileType.value),
      );
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(
        $DocumentsTable.$converterexpiryDaten.toSql(expiryDate.value),
      );
    }
    if (expiryReminder.present) {
      map['expiry_reminder'] = Variable<bool>(expiryReminder.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (driveStatus.present) {
      map['drive_status'] = Variable<String>(
        $DocumentsTable.$converterdriveStatus.toSql(driveStatus.value),
      );
    }
    if (driveFileId.present) {
      map['drive_file_id'] = Variable<String>(driveFileId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('fileKey: $fileKey, ')
          ..write('originalName: $originalName, ')
          ..write('fileType: $fileType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('expiryReminder: $expiryReminder, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('driveStatus: $driveStatus, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DocumentsFts extends Table
    with
        TableInfo<DocumentsFts, DocumentsFt>,
        VirtualTableInfo<DocumentsFts, DocumentsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DocumentsFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [title, description, originalName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentsFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DocumentsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentsFt(
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
    );
  }

  @override
  DocumentsFts createAlias(String alias) {
    return DocumentsFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, description, original_name, content=\'documents\', content_rowid=\'rowid\')';
}

class DocumentsFt extends DataClass implements Insertable<DocumentsFt> {
  final String title;
  final String description;
  final String originalName;
  const DocumentsFt({
    required this.title,
    required this.description,
    required this.originalName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['original_name'] = Variable<String>(originalName);
    return map;
  }

  DocumentsFtsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsFtsCompanion(
      title: Value(title),
      description: Value(description),
      originalName: Value(originalName),
    );
  }

  factory DocumentsFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentsFt(
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      originalName: serializer.fromJson<String>(json['original_name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'original_name': serializer.toJson<String>(originalName),
    };
  }

  DocumentsFt copyWith({
    String? title,
    String? description,
    String? originalName,
  }) => DocumentsFt(
    title: title ?? this.title,
    description: description ?? this.description,
    originalName: originalName ?? this.originalName,
  );
  DocumentsFt copyWithCompanion(DocumentsFtsCompanion data) {
    return DocumentsFt(
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsFt(')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('originalName: $originalName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, description, originalName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentsFt &&
          other.title == this.title &&
          other.description == this.description &&
          other.originalName == this.originalName);
}

class DocumentsFtsCompanion extends UpdateCompanion<DocumentsFt> {
  final Value<String> title;
  final Value<String> description;
  final Value<String> originalName;
  final Value<int> rowid;
  const DocumentsFtsCompanion({
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.originalName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsFtsCompanion.insert({
    required String title,
    required String description,
    required String originalName,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       description = Value(description),
       originalName = Value(originalName);
  static Insertable<DocumentsFt> custom({
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? originalName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (originalName != null) 'original_name': originalName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsFtsCompanion copyWith({
    Value<String>? title,
    Value<String>? description,
    Value<String>? originalName,
    Value<int>? rowid,
  }) {
    return DocumentsFtsCompanion(
      title: title ?? this.title,
      description: description ?? this.description,
      originalName: originalName ?? this.originalName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsFtsCompanion(')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('originalName: $originalName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PasswordNotesTable extends PasswordNotes
    with TableInfo<$PasswordNotesTable, PasswordNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PasswordNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    url,
    username,
    password,
    notes,
    category,
    isFavourite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'password_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PasswordNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PasswordNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PasswordNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
    );
  }

  @override
  $PasswordNotesTable createAlias(String alias) {
    return $PasswordNotesTable(attachedDatabase, alias);
  }
}

class PasswordNoteRow extends DataClass implements Insertable<PasswordNoteRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String url;
  final String username;

  /// Never indexed for search.
  final String password;
  final String notes;
  final String category;
  final bool isFavourite;
  const PasswordNoteRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.notes,
    required this.category,
    required this.isFavourite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['notes'] = Variable<String>(notes);
    map['category'] = Variable<String>(category);
    map['is_favourite'] = Variable<bool>(isFavourite);
    return map;
  }

  PasswordNotesCompanion toCompanion(bool nullToAbsent) {
    return PasswordNotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      url: Value(url),
      username: Value(username),
      password: Value(password),
      notes: Value(notes),
      category: Value(category),
      isFavourite: Value(isFavourite),
    );
  }

  factory PasswordNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PasswordNoteRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      notes: serializer.fromJson<String>(json['notes']),
      category: serializer.fromJson<String>(json['category']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'notes': serializer.toJson<String>(notes),
      'category': serializer.toJson<String>(category),
      'isFavourite': serializer.toJson<bool>(isFavourite),
    };
  }

  PasswordNoteRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? url,
    String? username,
    String? password,
    String? notes,
    String? category,
    bool? isFavourite,
  }) => PasswordNoteRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    url: url ?? this.url,
    username: username ?? this.username,
    password: password ?? this.password,
    notes: notes ?? this.notes,
    category: category ?? this.category,
    isFavourite: isFavourite ?? this.isFavourite,
  );
  PasswordNoteRow copyWithCompanion(PasswordNotesCompanion data) {
    return PasswordNoteRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      notes: data.notes.present ? data.notes.value : this.notes,
      category: data.category.present ? data.category.value : this.category,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PasswordNoteRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('notes: $notes, ')
          ..write('category: $category, ')
          ..write('isFavourite: $isFavourite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    name,
    url,
    username,
    password,
    notes,
    category,
    isFavourite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordNoteRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.url == this.url &&
          other.username == this.username &&
          other.password == this.password &&
          other.notes == this.notes &&
          other.category == this.category &&
          other.isFavourite == this.isFavourite);
}

class PasswordNotesCompanion extends UpdateCompanion<PasswordNoteRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<String> url;
  final Value<String> username;
  final Value<String> password;
  final Value<String> notes;
  final Value<String> category;
  final Value<bool> isFavourite;
  final Value<int> rowid;
  const PasswordNotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.notes = const Value.absent(),
    this.category = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PasswordNotesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String name,
    this.url = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.notes = const Value.absent(),
    this.category = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<PasswordNoteRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? notes,
    Expression<String>? category,
    Expression<bool>? isFavourite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (notes != null) 'notes': notes,
      if (category != null) 'category': category,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PasswordNotesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<String>? url,
    Value<String>? username,
    Value<String>? password,
    Value<String>? notes,
    Value<String>? category,
    Value<bool>? isFavourite,
    Value<int>? rowid,
  }) {
    return PasswordNotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      isFavourite: isFavourite ?? this.isFavourite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PasswordNotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('notes: $notes, ')
          ..write('category: $category, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PasswordNotesFts extends Table
    with
        TableInfo<PasswordNotesFts, PasswordNotesFt>,
        VirtualTableInfo<PasswordNotesFts, PasswordNotesFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PasswordNotesFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [name, url, username];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'password_notes_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PasswordNotesFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PasswordNotesFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PasswordNotesFt(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
    );
  }

  @override
  PasswordNotesFts createAlias(String alias) {
    return PasswordNotesFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(name, url, username, content=\'password_notes\', content_rowid=\'rowid\')';
}

class PasswordNotesFt extends DataClass implements Insertable<PasswordNotesFt> {
  final String name;
  final String url;
  final String username;
  const PasswordNotesFt({
    required this.name,
    required this.url,
    required this.username,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['username'] = Variable<String>(username);
    return map;
  }

  PasswordNotesFtsCompanion toCompanion(bool nullToAbsent) {
    return PasswordNotesFtsCompanion(
      name: Value(name),
      url: Value(url),
      username: Value(username),
    );
  }

  factory PasswordNotesFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PasswordNotesFt(
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      username: serializer.fromJson<String>(json['username']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'username': serializer.toJson<String>(username),
    };
  }

  PasswordNotesFt copyWith({String? name, String? url, String? username}) =>
      PasswordNotesFt(
        name: name ?? this.name,
        url: url ?? this.url,
        username: username ?? this.username,
      );
  PasswordNotesFt copyWithCompanion(PasswordNotesFtsCompanion data) {
    return PasswordNotesFt(
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      username: data.username.present ? data.username.value : this.username,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PasswordNotesFt(')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, url, username);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordNotesFt &&
          other.name == this.name &&
          other.url == this.url &&
          other.username == this.username);
}

class PasswordNotesFtsCompanion extends UpdateCompanion<PasswordNotesFt> {
  final Value<String> name;
  final Value<String> url;
  final Value<String> username;
  final Value<int> rowid;
  const PasswordNotesFtsCompanion({
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.username = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PasswordNotesFtsCompanion.insert({
    required String name,
    required String url,
    required String username,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       url = Value(url),
       username = Value(username);
  static Insertable<PasswordNotesFt> custom({
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? username,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (username != null) 'username': username,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PasswordNotesFtsCompanion copyWith({
    Value<String>? name,
    Value<String>? url,
    Value<String>? username,
    Value<int>? rowid,
  }) {
    return PasswordNotesFtsCompanion(
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PasswordNotesFtsCompanion(')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('username: $username, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalEntriesTable extends PersonalEntries
    with TableInfo<$PersonalEntriesTable, PersonalEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  @override
  late final GeneratedColumnWithTypeConverter<DetailKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DetailKind>($PersonalEntriesTable.$converterkind);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<DetailField>, String>
  fieldsJson =
      GeneratedColumn<String>(
        'fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<DetailField>>(
        $PersonalEntriesTable.$converterfieldsJson,
      );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  linkedDocumentIds =
      GeneratedColumn<String>(
        'linked_document_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>(
        $PersonalEntriesTable.$converterlinkedDocumentIds,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    kind,
    title,
    fieldsJson,
    searchText,
    linkedDocumentIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      kind: $PersonalEntriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      fieldsJson: $PersonalEntriesTable.$converterfieldsJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fields_json'],
        )!,
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      linkedDocumentIds: $PersonalEntriesTable.$converterlinkedDocumentIds
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}linked_document_ids'],
            )!,
          ),
    );
  }

  @override
  $PersonalEntriesTable createAlias(String alias) {
    return $PersonalEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DetailKind, String, String> $converterkind =
      const EnumNameConverter<DetailKind>(DetailKind.values);
  static TypeConverter<List<DetailField>, String> $converterfieldsJson =
      const DetailFieldsConverter();
  static TypeConverter<List<String>, String> $converterlinkedDocumentIds =
      const StringListConverter();
}

class PersonalEntryRow extends DataClass
    implements Insertable<PersonalEntryRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DetailKind kind;
  final String title;

  /// Ordered fields as JSON.
  final List<DetailField> fieldsJson;

  /// Plain text of every value, indexed for search.
  final String searchText;

  /// Ids of linked documents (no file duplication).
  final List<String> linkedDocumentIds;
  const PersonalEntryRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.kind,
    required this.title,
    required this.fieldsJson,
    required this.searchText,
    required this.linkedDocumentIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['kind'] = Variable<String>(
        $PersonalEntriesTable.$converterkind.toSql(kind),
      );
    }
    map['title'] = Variable<String>(title);
    {
      map['fields_json'] = Variable<String>(
        $PersonalEntriesTable.$converterfieldsJson.toSql(fieldsJson),
      );
    }
    map['search_text'] = Variable<String>(searchText);
    {
      map['linked_document_ids'] = Variable<String>(
        $PersonalEntriesTable.$converterlinkedDocumentIds.toSql(
          linkedDocumentIds,
        ),
      );
    }
    return map;
  }

  PersonalEntriesCompanion toCompanion(bool nullToAbsent) {
    return PersonalEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      kind: Value(kind),
      title: Value(title),
      fieldsJson: Value(fieldsJson),
      searchText: Value(searchText),
      linkedDocumentIds: Value(linkedDocumentIds),
    );
  }

  factory PersonalEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalEntryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      kind: $PersonalEntriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      title: serializer.fromJson<String>(json['title']),
      fieldsJson: serializer.fromJson<List<DetailField>>(json['fieldsJson']),
      searchText: serializer.fromJson<String>(json['searchText']),
      linkedDocumentIds: serializer.fromJson<List<String>>(
        json['linkedDocumentIds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'kind': serializer.toJson<String>(
        $PersonalEntriesTable.$converterkind.toJson(kind),
      ),
      'title': serializer.toJson<String>(title),
      'fieldsJson': serializer.toJson<List<DetailField>>(fieldsJson),
      'searchText': serializer.toJson<String>(searchText),
      'linkedDocumentIds': serializer.toJson<List<String>>(linkedDocumentIds),
    };
  }

  PersonalEntryRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DetailKind? kind,
    String? title,
    List<DetailField>? fieldsJson,
    String? searchText,
    List<String>? linkedDocumentIds,
  }) => PersonalEntryRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    searchText: searchText ?? this.searchText,
    linkedDocumentIds: linkedDocumentIds ?? this.linkedDocumentIds,
  );
  PersonalEntryRow copyWithCompanion(PersonalEntriesCompanion data) {
    return PersonalEntryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      linkedDocumentIds: data.linkedDocumentIds.present
          ? data.linkedDocumentIds.value
          : this.linkedDocumentIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalEntryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('searchText: $searchText, ')
          ..write('linkedDocumentIds: $linkedDocumentIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    kind,
    title,
    fieldsJson,
    searchText,
    linkedDocumentIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalEntryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.fieldsJson == this.fieldsJson &&
          other.searchText == this.searchText &&
          other.linkedDocumentIds == this.linkedDocumentIds);
}

class PersonalEntriesCompanion extends UpdateCompanion<PersonalEntryRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DetailKind> kind;
  final Value<String> title;
  final Value<List<DetailField>> fieldsJson;
  final Value<String> searchText;
  final Value<List<String>> linkedDocumentIds;
  final Value<int> rowid;
  const PersonalEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.searchText = const Value.absent(),
    this.linkedDocumentIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalEntriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DetailKind kind,
    this.title = const Value.absent(),
    required List<DetailField> fieldsJson,
    this.searchText = const Value.absent(),
    this.linkedDocumentIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       kind = Value(kind),
       fieldsJson = Value(fieldsJson);
  static Insertable<PersonalEntryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? fieldsJson,
    Expression<String>? searchText,
    Expression<String>? linkedDocumentIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (searchText != null) 'search_text': searchText,
      if (linkedDocumentIds != null) 'linked_document_ids': linkedDocumentIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DetailKind>? kind,
    Value<String>? title,
    Value<List<DetailField>>? fieldsJson,
    Value<String>? searchText,
    Value<List<String>>? linkedDocumentIds,
    Value<int>? rowid,
  }) {
    return PersonalEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      searchText: searchText ?? this.searchText,
      linkedDocumentIds: linkedDocumentIds ?? this.linkedDocumentIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PersonalEntriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(
        $PersonalEntriesTable.$converterfieldsJson.toSql(fieldsJson.value),
      );
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (linkedDocumentIds.present) {
      map['linked_document_ids'] = Variable<String>(
        $PersonalEntriesTable.$converterlinkedDocumentIds.toSql(
          linkedDocumentIds.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('searchText: $searchText, ')
          ..write('linkedDocumentIds: $linkedDocumentIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PersonalEntriesFts extends Table
    with
        TableInfo<PersonalEntriesFts, PersonalEntriesFt>,
        VirtualTableInfo<PersonalEntriesFts, PersonalEntriesFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PersonalEntriesFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [title, searchText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_entries_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalEntriesFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PersonalEntriesFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalEntriesFt(
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  PersonalEntriesFts createAlias(String alias) {
    return PersonalEntriesFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, search_text, content=\'personal_entries\', content_rowid=\'rowid\')';
}

class PersonalEntriesFt extends DataClass
    implements Insertable<PersonalEntriesFt> {
  final String title;
  final String searchText;
  const PersonalEntriesFt({required this.title, required this.searchText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  PersonalEntriesFtsCompanion toCompanion(bool nullToAbsent) {
    return PersonalEntriesFtsCompanion(
      title: Value(title),
      searchText: Value(searchText),
    );
  }

  factory PersonalEntriesFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalEntriesFt(
      title: serializer.fromJson<String>(json['title']),
      searchText: serializer.fromJson<String>(json['search_text']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'search_text': serializer.toJson<String>(searchText),
    };
  }

  PersonalEntriesFt copyWith({String? title, String? searchText}) =>
      PersonalEntriesFt(
        title: title ?? this.title,
        searchText: searchText ?? this.searchText,
      );
  PersonalEntriesFt copyWithCompanion(PersonalEntriesFtsCompanion data) {
    return PersonalEntriesFt(
      title: data.title.present ? data.title.value : this.title,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalEntriesFt(')
          ..write('title: $title, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, searchText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalEntriesFt &&
          other.title == this.title &&
          other.searchText == this.searchText);
}

class PersonalEntriesFtsCompanion extends UpdateCompanion<PersonalEntriesFt> {
  final Value<String> title;
  final Value<String> searchText;
  final Value<int> rowid;
  const PersonalEntriesFtsCompanion({
    this.title = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalEntriesFtsCompanion.insert({
    required String title,
    required String searchText,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       searchText = Value(searchText);
  static Insertable<PersonalEntriesFt> custom({
    Expression<String>? title,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalEntriesFtsCompanion copyWith({
    Value<String>? title,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return PersonalEntriesFtsCompanion(
      title: title ?? this.title,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalEntriesFtsCompanion(')
          ..write('title: $title, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    createdAt,
    updatedAt,
    title,
    contentJson,
    plainText,
    tags,
    isPinned,
    isFavourite,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
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
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      )!,
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;

  /// Rich text as a Quill Delta (JSON).
  final String contentJson;

  /// Plain-text projection of the content, indexed for search.
  final String plainText;

  /// Lower-case tags separated by single spaces (also indexed).
  final String tags;
  final bool isPinned;
  final bool isFavourite;
  final bool isArchived;
  const NoteRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.contentJson,
    required this.plainText,
    required this.tags,
    required this.isPinned,
    required this.isFavourite,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    map['content_json'] = Variable<String>(contentJson);
    map['plain_text'] = Variable<String>(plainText);
    map['tags'] = Variable<String>(tags);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_favourite'] = Variable<bool>(isFavourite);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      contentJson: Value(contentJson),
      plainText: Value(plainText),
      tags: Value(tags),
      isPinned: Value(isPinned),
      isFavourite: Value(isFavourite),
      isArchived: Value(isArchived),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
      plainText: serializer.fromJson<String>(json['plainText']),
      tags: serializer.fromJson<String>(json['tags']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'contentJson': serializer.toJson<String>(contentJson),
      'plainText': serializer.toJson<String>(plainText),
      'tags': serializer.toJson<String>(tags),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  NoteRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? contentJson,
    String? plainText,
    String? tags,
    bool? isPinned,
    bool? isFavourite,
    bool? isArchived,
  }) => NoteRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title ?? this.title,
    contentJson: contentJson ?? this.contentJson,
    plainText: plainText ?? this.plainText,
    tags: tags ?? this.tags,
    isPinned: isPinned ?? this.isPinned,
    isFavourite: isFavourite ?? this.isFavourite,
    isArchived: isArchived ?? this.isArchived,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      tags: data.tags.present ? data.tags.value : this.tags,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('contentJson: $contentJson, ')
          ..write('plainText: $plainText, ')
          ..write('tags: $tags, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    title,
    contentJson,
    plainText,
    tags,
    isPinned,
    isFavourite,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.contentJson == this.contentJson &&
          other.plainText == this.plainText &&
          other.tags == this.tags &&
          other.isPinned == this.isPinned &&
          other.isFavourite == this.isFavourite &&
          other.isArchived == this.isArchived);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String> contentJson;
  final Value<String> plainText;
  final Value<String> tags;
  final Value<bool> isPinned;
  final Value<bool> isFavourite;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.plainText = const Value.absent(),
    this.tags = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.title = const Value.absent(),
    required String contentJson,
    this.plainText = const Value.absent(),
    this.tags = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       contentJson = Value(contentJson);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? contentJson,
    Expression<String>? plainText,
    Expression<String>? tags,
    Expression<bool>? isPinned,
    Expression<bool>? isFavourite,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (contentJson != null) 'content_json': contentJson,
      if (plainText != null) 'plain_text': plainText,
      if (tags != null) 'tags': tags,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? title,
    Value<String>? contentJson,
    Value<String>? plainText,
    Value<String>? tags,
    Value<bool>? isPinned,
    Value<bool>? isFavourite,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      plainText: plainText ?? this.plainText,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isFavourite: isFavourite ?? this.isFavourite,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
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
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('contentJson: $contentJson, ')
          ..write('plainText: $plainText, ')
          ..write('tags: $tags, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class NotesFts extends Table
    with TableInfo<NotesFts, NotesFt>, VirtualTableInfo<NotesFts, NotesFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  NotesFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [title, plainText, tags];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotesFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    } else if (isInserting) {
      context.missing(_plainTextMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  NotesFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotesFt(
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
    );
  }

  @override
  NotesFts createAlias(String alias) {
    return NotesFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, plain_text, tags, content=\'notes\', content_rowid=\'rowid\')';
}

class NotesFt extends DataClass implements Insertable<NotesFt> {
  final String title;
  final String plainText;
  final String tags;
  const NotesFt({
    required this.title,
    required this.plainText,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['plain_text'] = Variable<String>(plainText);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  NotesFtsCompanion toCompanion(bool nullToAbsent) {
    return NotesFtsCompanion(
      title: Value(title),
      plainText: Value(plainText),
      tags: Value(tags),
    );
  }

  factory NotesFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotesFt(
      title: serializer.fromJson<String>(json['title']),
      plainText: serializer.fromJson<String>(json['plain_text']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'plain_text': serializer.toJson<String>(plainText),
      'tags': serializer.toJson<String>(tags),
    };
  }

  NotesFt copyWith({String? title, String? plainText, String? tags}) => NotesFt(
    title: title ?? this.title,
    plainText: plainText ?? this.plainText,
    tags: tags ?? this.tags,
  );
  NotesFt copyWithCompanion(NotesFtsCompanion data) {
    return NotesFt(
      title: data.title.present ? data.title.value : this.title,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotesFt(')
          ..write('title: $title, ')
          ..write('plainText: $plainText, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, plainText, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotesFt &&
          other.title == this.title &&
          other.plainText == this.plainText &&
          other.tags == this.tags);
}

class NotesFtsCompanion extends UpdateCompanion<NotesFt> {
  final Value<String> title;
  final Value<String> plainText;
  final Value<String> tags;
  final Value<int> rowid;
  const NotesFtsCompanion({
    this.title = const Value.absent(),
    this.plainText = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesFtsCompanion.insert({
    required String title,
    required String plainText,
    required String tags,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       plainText = Value(plainText),
       tags = Value(tags);
  static Insertable<NotesFt> custom({
    Expression<String>? title,
    Expression<String>? plainText,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (plainText != null) 'plain_text': plainText,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesFtsCompanion copyWith({
    Value<String>? title,
    Value<String>? plainText,
    Value<String>? tags,
    Value<int>? rowid,
  }) {
    return NotesFtsCompanion(
      title: title ?? this.title,
      plainText: plainText ?? this.plainText,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesFtsCompanion(')
          ..write('title: $title, ')
          ..write('plainText: $plainText, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteAttachmentsTable extends NoteAttachments
    with TableInfo<$NoteAttachmentsTable, NoteAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileKeyMeta = const VerificationMeta(
    'fileKey',
  );
  @override
  late final GeneratedColumn<String> fileKey = GeneratedColumn<String>(
    'file_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    noteId,
    fileKey,
    originalName,
    mimeType,
    sizeBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('file_key')) {
      context.handle(
        _fileKeyMeta,
        fileKey.isAcceptableOrUnknown(data['file_key']!, _fileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fileKeyMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteAttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      fileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_key'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
    );
  }

  @override
  $NoteAttachmentsTable createAlias(String alias) {
    return $NoteAttachmentsTable(attachedDatabase, alias);
  }
}

class NoteAttachmentRow extends DataClass
    implements Insertable<NoteAttachmentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String noteId;

  /// Key in the app's FileStore (never the original file name).
  final String fileKey;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  const NoteAttachmentRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.noteId,
    required this.fileKey,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['note_id'] = Variable<String>(noteId);
    map['file_key'] = Variable<String>(fileKey);
    map['original_name'] = Variable<String>(originalName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    return map;
  }

  NoteAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return NoteAttachmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      noteId: Value(noteId),
      fileKey: Value(fileKey),
      originalName: Value(originalName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
    );
  }

  factory NoteAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteAttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      noteId: serializer.fromJson<String>(json['noteId']),
      fileKey: serializer.fromJson<String>(json['fileKey']),
      originalName: serializer.fromJson<String>(json['originalName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'noteId': serializer.toJson<String>(noteId),
      'fileKey': serializer.toJson<String>(fileKey),
      'originalName': serializer.toJson<String>(originalName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
    };
  }

  NoteAttachmentRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? noteId,
    String? fileKey,
    String? originalName,
    String? mimeType,
    int? sizeBytes,
  }) => NoteAttachmentRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    noteId: noteId ?? this.noteId,
    fileKey: fileKey ?? this.fileKey,
    originalName: originalName ?? this.originalName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
  );
  NoteAttachmentRow copyWithCompanion(NoteAttachmentsCompanion data) {
    return NoteAttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      fileKey: data.fileKey.present ? data.fileKey.value : this.fileKey,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteAttachmentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('noteId: $noteId, ')
          ..write('fileKey: $fileKey, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    noteId,
    fileKey,
    originalName,
    mimeType,
    sizeBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteAttachmentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.noteId == this.noteId &&
          other.fileKey == this.fileKey &&
          other.originalName == this.originalName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes);
}

class NoteAttachmentsCompanion extends UpdateCompanion<NoteAttachmentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> noteId;
  final Value<String> fileKey;
  final Value<String> originalName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<int> rowid;
  const NoteAttachmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.noteId = const Value.absent(),
    this.fileKey = const Value.absent(),
    this.originalName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteAttachmentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String noteId,
    required String fileKey,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       noteId = Value(noteId),
       fileKey = Value(fileKey),
       originalName = Value(originalName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes);
  static Insertable<NoteAttachmentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? noteId,
    Expression<String>? fileKey,
    Expression<String>? originalName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (noteId != null) 'note_id': noteId,
      if (fileKey != null) 'file_key': fileKey,
      if (originalName != null) 'original_name': originalName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? noteId,
    Value<String>? fileKey,
    Value<String>? originalName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<int>? rowid,
  }) {
    return NoteAttachmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      noteId: noteId ?? this.noteId,
      fileKey: fileKey ?? this.fileKey,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (fileKey.present) {
      map['file_key'] = Variable<String>(fileKey.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('noteId: $noteId, ')
          ..write('fileKey: $fileKey, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$converterdueDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> reminderAt =
      GeneratedColumn<String>(
        'reminder_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$converterreminderAtn);
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    title,
    description,
    dueDate,
    reminderAt,
    isCompleted,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dueDate: $TasksTable.$converterdueDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        ),
      ),
      reminderAt: $TasksTable.$converterreminderAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_at'],
        ),
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdueDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterdueDaten =
      NullAwareTypeConverter.wrap($converterdueDate);
  static TypeConverter<DateTime, String> $converterreminderAt =
      const WallClockConverter();
  static TypeConverter<DateTime?, String?> $converterreminderAtn =
      NullAwareTypeConverter.wrap($converterreminderAt);
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String description;
  final DateTime? dueDate;

  /// Optional reminder (local wall-clock time).
  final DateTime? reminderAt;
  final bool isCompleted;
  final DateTime? completedAt;
  const TaskRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.description,
    this.dueDate,
    this.reminderAt,
    required this.isCompleted,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(
        $TasksTable.$converterdueDaten.toSql(dueDate),
      );
    }
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<String>(
        $TasksTable.$converterreminderAtn.toSql(reminderAt),
      );
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      description: Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      reminderAt: serializer.fromJson<DateTime?>(json['reminderAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'reminderAt': serializer.toJson<DateTime?>(reminderAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  TaskRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> reminderAt = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      reminderAt: data.reminderAt.present
          ? data.reminderAt.value
          : this.reminderAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    title,
    description,
    dueDate,
    reminderAt,
    isCompleted,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.reminderAt == this.reminderAt &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> reminderAt;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? dueDate,
    Expression<String>? reminderAt,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? reminderAt,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $TasksTable.$converterdueDaten.toSql(dueDate.value),
      );
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<String>(
        $TasksTable.$converterreminderAtn.toSql(reminderAt.value),
      );
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskChecklistItemsTable extends TaskChecklistItems
    with TableInfo<$TaskChecklistItemsTable, ChecklistItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    taskId,
    label,
    isDone,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_checklist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChecklistItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TaskChecklistItemsTable createAlias(String alias) {
    return $TaskChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistItemRow extends DataClass
    implements Insertable<ChecklistItemRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String taskId;
  final String label;
  final bool isDone;
  final int position;
  const ChecklistItemRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.taskId,
    required this.label,
    required this.isDone,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['task_id'] = Variable<String>(taskId);
    map['label'] = Variable<String>(label);
    map['is_done'] = Variable<bool>(isDone);
    map['position'] = Variable<int>(position);
    return map;
  }

  TaskChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return TaskChecklistItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      taskId: Value(taskId),
      label: Value(label),
      isDone: Value(isDone),
      position: Value(position),
    );
  }

  factory ChecklistItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistItemRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      taskId: serializer.fromJson<String>(json['taskId']),
      label: serializer.fromJson<String>(json['label']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'taskId': serializer.toJson<String>(taskId),
      'label': serializer.toJson<String>(label),
      'isDone': serializer.toJson<bool>(isDone),
      'position': serializer.toJson<int>(position),
    };
  }

  ChecklistItemRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? taskId,
    String? label,
    bool? isDone,
    int? position,
  }) => ChecklistItemRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    taskId: taskId ?? this.taskId,
    label: label ?? this.label,
    isDone: isDone ?? this.isDone,
    position: position ?? this.position,
  );
  ChecklistItemRow copyWithCompanion(TaskChecklistItemsCompanion data) {
    return ChecklistItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      label: data.label.present ? data.label.value : this.label,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('taskId: $taskId, ')
          ..write('label: $label, ')
          ..write('isDone: $isDone, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, taskId, label, isDone, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.taskId == this.taskId &&
          other.label == this.label &&
          other.isDone == this.isDone &&
          other.position == this.position);
}

class TaskChecklistItemsCompanion extends UpdateCompanion<ChecklistItemRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> taskId;
  final Value<String> label;
  final Value<bool> isDone;
  final Value<int> position;
  final Value<int> rowid;
  const TaskChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.label = const Value.absent(),
    this.isDone = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskChecklistItemsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String taskId,
    required String label,
    this.isDone = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       taskId = Value(taskId),
       label = Value(label),
       position = Value(position);
  static Insertable<ChecklistItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? taskId,
    Expression<String>? label,
    Expression<bool>? isDone,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (taskId != null) 'task_id': taskId,
      if (label != null) 'label': label,
      if (isDone != null) 'is_done': isDone,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskChecklistItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? taskId,
    Value<String>? label,
    Value<bool>? isDone,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TaskChecklistItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskId: taskId ?? this.taskId,
      label: label ?? this.label,
      isDone: isDone ?? this.isDone,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('taskId: $taskId, ')
          ..write('label: $label, ')
          ..write('isDone: $isDone, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> anchorAt =
      GeneratedColumn<String>(
        'anchor_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RemindersTable.$converteranchorAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> dueAt =
      GeneratedColumn<String>(
        'due_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RemindersTable.$converterdueAt);
  @override
  late final GeneratedColumnWithTypeConverter<RepeatFrequency, String> repeat =
      GeneratedColumn<String>(
        'repeat',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RepeatFrequency>($RemindersTable.$converterrepeat);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> snoozedUntil =
      GeneratedColumn<String>(
        'snoozed_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RemindersTable.$convertersnoozedUntiln);
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    title,
    description,
    anchorAt,
    dueAt,
    repeat,
    snoozedUntil,
    isCompleted,
    completedAt,
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
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
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      anchorAt: $RemindersTable.$converteranchorAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}anchor_at'],
        )!,
      ),
      dueAt: $RemindersTable.$converterdueAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_at'],
        )!,
      ),
      repeat: $RemindersTable.$converterrepeat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}repeat'],
        )!,
      ),
      snoozedUntil: $RemindersTable.$convertersnoozedUntiln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}snoozed_until'],
        ),
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converteranchorAt =
      const WallClockConverter();
  static TypeConverter<DateTime, String> $converterdueAt =
      const WallClockConverter();
  static JsonTypeConverter2<RepeatFrequency, String, String> $converterrepeat =
      const EnumNameConverter<RepeatFrequency>(RepeatFrequency.values);
  static TypeConverter<DateTime, String> $convertersnoozedUntil =
      const WallClockConverter();
  static TypeConverter<DateTime?, String?> $convertersnoozedUntiln =
      NullAwareTypeConverter.wrap($convertersnoozedUntil);
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String description;

  /// First occurrence; repeats are computed from it (keeps month-end and
  /// leap-day clamping exact).
  final DateTime anchorAt;

  /// The occurrence currently waiting to be marked done.
  final DateTime dueAt;
  final RepeatFrequency repeat;

  /// In-app snooze of a repeating reminder (one extra notification).
  final DateTime? snoozedUntil;
  final bool isCompleted;
  final DateTime? completedAt;
  const ReminderRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.description,
    required this.anchorAt,
    required this.dueAt,
    required this.repeat,
    this.snoozedUntil,
    required this.isCompleted,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['anchor_at'] = Variable<String>(
        $RemindersTable.$converteranchorAt.toSql(anchorAt),
      );
    }
    {
      map['due_at'] = Variable<String>(
        $RemindersTable.$converterdueAt.toSql(dueAt),
      );
    }
    {
      map['repeat'] = Variable<String>(
        $RemindersTable.$converterrepeat.toSql(repeat),
      );
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<String>(
        $RemindersTable.$convertersnoozedUntiln.toSql(snoozedUntil),
      );
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      description: Value(description),
      anchorAt: Value(anchorAt),
      dueAt: Value(dueAt),
      repeat: Value(repeat),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      anchorAt: serializer.fromJson<DateTime>(json['anchorAt']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      repeat: $RemindersTable.$converterrepeat.fromJson(
        serializer.fromJson<String>(json['repeat']),
      ),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'anchorAt': serializer.toJson<DateTime>(anchorAt),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'repeat': serializer.toJson<String>(
        $RemindersTable.$converterrepeat.toJson(repeat),
      ),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ReminderRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    DateTime? anchorAt,
    DateTime? dueAt,
    RepeatFrequency? repeat,
    Value<DateTime?> snoozedUntil = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title ?? this.title,
    description: description ?? this.description,
    anchorAt: anchorAt ?? this.anchorAt,
    dueAt: dueAt ?? this.dueAt,
    repeat: repeat ?? this.repeat,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      anchorAt: data.anchorAt.present ? data.anchorAt.value : this.anchorAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('anchorAt: $anchorAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('repeat: $repeat, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    title,
    description,
    anchorAt,
    dueAt,
    repeat,
    snoozedUntil,
    isCompleted,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.anchorAt == this.anchorAt &&
          other.dueAt == this.dueAt &&
          other.repeat == this.repeat &&
          other.snoozedUntil == this.snoozedUntil &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> anchorAt;
  final Value<DateTime> dueAt;
  final Value<RepeatFrequency> repeat;
  final Value<DateTime?> snoozedUntil;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.anchorAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.repeat = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String title,
    this.description = const Value.absent(),
    required DateTime anchorAt,
    required DateTime dueAt,
    required RepeatFrequency repeat,
    this.snoozedUntil = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       anchorAt = Value(anchorAt),
       dueAt = Value(dueAt),
       repeat = Value(repeat);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? anchorAt,
    Expression<String>? dueAt,
    Expression<String>? repeat,
    Expression<String>? snoozedUntil,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (anchorAt != null) 'anchor_at': anchorAt,
      if (dueAt != null) 'due_at': dueAt,
      if (repeat != null) 'repeat': repeat,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? anchorAt,
    Value<DateTime>? dueAt,
    Value<RepeatFrequency>? repeat,
    Value<DateTime?>? snoozedUntil,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      anchorAt: anchorAt ?? this.anchorAt,
      dueAt: dueAt ?? this.dueAt,
      repeat: repeat ?? this.repeat,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (anchorAt.present) {
      map['anchor_at'] = Variable<String>(
        $RemindersTable.$converteranchorAt.toSql(anchorAt.value),
      );
    }
    if (dueAt.present) {
      map['due_at'] = Variable<String>(
        $RemindersTable.$converterdueAt.toSql(dueAt.value),
      );
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(
        $RemindersTable.$converterrepeat.toSql(repeat.value),
      );
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<String>(
        $RemindersTable.$convertersnoozedUntiln.toSql(snoozedUntil.value),
      );
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('anchorAt: $anchorAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('repeat: $repeat, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> spentOn =
      GeneratedColumn<String>(
        'spent_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpensesTable.$converterspentOn);
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExpenseSource>($ExpensesTable.$convertersource);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    amountPaise,
    description,
    spentOn,
    source,
    sourceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {source, sourceId},
  ];
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      spentOn: $ExpensesTable.$converterspentOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}spent_on'],
        )!,
      ),
      source: $ExpensesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterspentOn =
      const DateOnlyConverter();
  static JsonTypeConverter2<ExpenseSource, String, String> $convertersource =
      const EnumNameConverter<ExpenseSource>(ExpenseSource.values);
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int amountPaise;
  final String description;
  final DateTime spentOn;
  final ExpenseSource source;

  /// Null for manual expenses (NULLs never collide in a UNIQUE key).
  final String? sourceId;
  const ExpenseRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.amountPaise,
    required this.description,
    required this.spentOn,
    required this.source,
    this.sourceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['description'] = Variable<String>(description);
    {
      map['spent_on'] = Variable<String>(
        $ExpensesTable.$converterspentOn.toSql(spentOn),
      );
    }
    {
      map['source'] = Variable<String>(
        $ExpensesTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      amountPaise: Value(amountPaise),
      description: Value(description),
      spentOn: Value(spentOn),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      description: serializer.fromJson<String>(json['description']),
      spentOn: serializer.fromJson<DateTime>(json['spentOn']),
      source: $ExpensesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'description': serializer.toJson<String>(description),
      'spentOn': serializer.toJson<DateTime>(spentOn),
      'source': serializer.toJson<String>(
        $ExpensesTable.$convertersource.toJson(source),
      ),
      'sourceId': serializer.toJson<String?>(sourceId),
    };
  }

  ExpenseRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? amountPaise,
    String? description,
    DateTime? spentOn,
    ExpenseSource? source,
    Value<String?> sourceId = const Value.absent(),
  }) => ExpenseRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    amountPaise: amountPaise ?? this.amountPaise,
    description: description ?? this.description,
    spentOn: spentOn ?? this.spentOn,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      description: data.description.present
          ? data.description.value
          : this.description,
      spentOn: data.spentOn.present ? data.spentOn.value : this.spentOn,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('description: $description, ')
          ..write('spentOn: $spentOn, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    amountPaise,
    description,
    spentOn,
    source,
    sourceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.amountPaise == this.amountPaise &&
          other.description == this.description &&
          other.spentOn == this.spentOn &&
          other.source == this.source &&
          other.sourceId == this.sourceId);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> amountPaise;
  final Value<String> description;
  final Value<DateTime> spentOn;
  final Value<ExpenseSource> source;
  final Value<String?> sourceId;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.description = const Value.absent(),
    this.spentOn = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int amountPaise,
    this.description = const Value.absent(),
    required DateTime spentOn,
    required ExpenseSource source,
    this.sourceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       amountPaise = Value(amountPaise),
       spentOn = Value(spentOn),
       source = Value(source);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? amountPaise,
    Expression<String>? description,
    Expression<String>? spentOn,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (description != null) 'description': description,
      if (spentOn != null) 'spent_on': spentOn,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? amountPaise,
    Value<String>? description,
    Value<DateTime>? spentOn,
    Value<ExpenseSource>? source,
    Value<String?>? sourceId,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      amountPaise: amountPaise ?? this.amountPaise,
      description: description ?? this.description,
      spentOn: spentOn ?? this.spentOn,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (spentOn.present) {
      map['spent_on'] = Variable<String>(
        $ExpensesTable.$converterspentOn.toSql(spentOn.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ExpensesTable.$convertersource.toSql(source.value),
      );
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('description: $description, ')
          ..write('spentOn: $spentOn, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetAmountsTable extends BudgetAmounts
    with TableInfo<$BudgetAmountsTable, BudgetAmountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetAmountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _fromMonthMeta = const VerificationMeta(
    'fromMonth',
  );
  @override
  late final GeneratedColumn<String> fromMonth = GeneratedColumn<String>(
    'from_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    fromMonth,
    amountPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_amounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetAmountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('from_month')) {
      context.handle(
        _fromMonthMeta,
        fromMonth.isAcceptableOrUnknown(data['from_month']!, _fromMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_fromMonthMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetAmountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetAmountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      fromMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_month'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
    );
  }

  @override
  $BudgetAmountsTable createAlias(String alias) {
    return $BudgetAmountsTable(attachedDatabase, alias);
  }
}

class BudgetAmountRow extends DataClass implements Insertable<BudgetAmountRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// "yyyy-MM" (BudgetMonth.key); one row per month at most.
  final String fromMonth;
  final int amountPaise;
  const BudgetAmountRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fromMonth,
    required this.amountPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['from_month'] = Variable<String>(fromMonth);
    map['amount_paise'] = Variable<int>(amountPaise);
    return map;
  }

  BudgetAmountsCompanion toCompanion(bool nullToAbsent) {
    return BudgetAmountsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      fromMonth: Value(fromMonth),
      amountPaise: Value(amountPaise),
    );
  }

  factory BudgetAmountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetAmountRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      fromMonth: serializer.fromJson<String>(json['fromMonth']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'fromMonth': serializer.toJson<String>(fromMonth),
      'amountPaise': serializer.toJson<int>(amountPaise),
    };
  }

  BudgetAmountRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fromMonth,
    int? amountPaise,
  }) => BudgetAmountRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fromMonth: fromMonth ?? this.fromMonth,
    amountPaise: amountPaise ?? this.amountPaise,
  );
  BudgetAmountRow copyWithCompanion(BudgetAmountsCompanion data) {
    return BudgetAmountRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fromMonth: data.fromMonth.present ? data.fromMonth.value : this.fromMonth,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAmountRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fromMonth: $fromMonth, ')
          ..write('amountPaise: $amountPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, fromMonth, amountPaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetAmountRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.fromMonth == this.fromMonth &&
          other.amountPaise == this.amountPaise);
}

class BudgetAmountsCompanion extends UpdateCompanion<BudgetAmountRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> fromMonth;
  final Value<int> amountPaise;
  final Value<int> rowid;
  const BudgetAmountsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fromMonth = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetAmountsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String fromMonth,
    required int amountPaise,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       fromMonth = Value(fromMonth),
       amountPaise = Value(amountPaise);
  static Insertable<BudgetAmountRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? fromMonth,
    Expression<int>? amountPaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fromMonth != null) 'from_month': fromMonth,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetAmountsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? fromMonth,
    Value<int>? amountPaise,
    Value<int>? rowid,
  }) {
    return BudgetAmountsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fromMonth: fromMonth ?? this.fromMonth,
      amountPaise: amountPaise ?? this.amountPaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fromMonth.present) {
      map['from_month'] = Variable<String>(fromMonth.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAmountsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fromMonth: $fromMonth, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LendingRecordsTable extends LendingRecords
    with TableInfo<$LendingRecordsTable, LendingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LendingRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  @override
  late final GeneratedColumnWithTypeConverter<LendingDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LendingDirection>($LendingRecordsTable.$converterdirection);
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> givenOn =
      GeneratedColumn<String>(
        'given_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($LendingRecordsTable.$convertergivenOn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> dueOn =
      GeneratedColumn<String>(
        'due_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($LendingRecordsTable.$converterdueOnn);
  @override
  late final GeneratedColumnWithTypeConverter<LendingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LendingStatus>($LendingRecordsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> completedOn =
      GeneratedColumn<String>(
        'completed_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($LendingRecordsTable.$convertercompletedOnn);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remindMeta = const VerificationMeta('remind');
  @override
  late final GeneratedColumn<bool> remind = GeneratedColumn<bool>(
    'remind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    direction,
    person,
    amountPaise,
    givenOn,
    dueOn,
    status,
    completedOn,
    notes,
    remind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lending_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LendingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('remind')) {
      context.handle(
        _remindMeta,
        remind.isAcceptableOrUnknown(data['remind']!, _remindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LendingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LendingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      direction: $LendingRecordsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      givenOn: $LendingRecordsTable.$convertergivenOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}given_on'],
        )!,
      ),
      dueOn: $LendingRecordsTable.$converterdueOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_on'],
        ),
      ),
      status: $LendingRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      completedOn: $LendingRecordsTable.$convertercompletedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}completed_on'],
        ),
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      remind: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind'],
      )!,
    );
  }

  @override
  $LendingRecordsTable createAlias(String alias) {
    return $LendingRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LendingDirection, String, String>
  $converterdirection = const EnumNameConverter<LendingDirection>(
    LendingDirection.values,
  );
  static TypeConverter<DateTime, String> $convertergivenOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converterdueOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterdueOnn =
      NullAwareTypeConverter.wrap($converterdueOn);
  static JsonTypeConverter2<LendingStatus, String, String> $converterstatus =
      const EnumNameConverter<LendingStatus>(LendingStatus.values);
  static TypeConverter<DateTime, String> $convertercompletedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $convertercompletedOnn =
      NullAwareTypeConverter.wrap($convertercompletedOn);
}

class LendingRow extends DataClass implements Insertable<LendingRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LendingDirection direction;
  final String person;

  /// Integer paise (INR).
  final int amountPaise;
  final DateTime givenOn;
  final DateTime? dueOn;
  final LendingStatus status;
  final DateTime? completedOn;
  final String notes;
  final bool remind;
  const LendingRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.direction,
    required this.person,
    required this.amountPaise,
    required this.givenOn,
    this.dueOn,
    required this.status,
    this.completedOn,
    required this.notes,
    required this.remind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['direction'] = Variable<String>(
        $LendingRecordsTable.$converterdirection.toSql(direction),
      );
    }
    map['person'] = Variable<String>(person);
    map['amount_paise'] = Variable<int>(amountPaise);
    {
      map['given_on'] = Variable<String>(
        $LendingRecordsTable.$convertergivenOn.toSql(givenOn),
      );
    }
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<String>(
        $LendingRecordsTable.$converterdueOnn.toSql(dueOn),
      );
    }
    {
      map['status'] = Variable<String>(
        $LendingRecordsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || completedOn != null) {
      map['completed_on'] = Variable<String>(
        $LendingRecordsTable.$convertercompletedOnn.toSql(completedOn),
      );
    }
    map['notes'] = Variable<String>(notes);
    map['remind'] = Variable<bool>(remind);
    return map;
  }

  LendingRecordsCompanion toCompanion(bool nullToAbsent) {
    return LendingRecordsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      direction: Value(direction),
      person: Value(person),
      amountPaise: Value(amountPaise),
      givenOn: Value(givenOn),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
      status: Value(status),
      completedOn: completedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(completedOn),
      notes: Value(notes),
      remind: Value(remind),
    );
  }

  factory LendingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LendingRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      direction: $LendingRecordsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      person: serializer.fromJson<String>(json['person']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      givenOn: serializer.fromJson<DateTime>(json['givenOn']),
      dueOn: serializer.fromJson<DateTime?>(json['dueOn']),
      status: $LendingRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      completedOn: serializer.fromJson<DateTime?>(json['completedOn']),
      notes: serializer.fromJson<String>(json['notes']),
      remind: serializer.fromJson<bool>(json['remind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'direction': serializer.toJson<String>(
        $LendingRecordsTable.$converterdirection.toJson(direction),
      ),
      'person': serializer.toJson<String>(person),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'givenOn': serializer.toJson<DateTime>(givenOn),
      'dueOn': serializer.toJson<DateTime?>(dueOn),
      'status': serializer.toJson<String>(
        $LendingRecordsTable.$converterstatus.toJson(status),
      ),
      'completedOn': serializer.toJson<DateTime?>(completedOn),
      'notes': serializer.toJson<String>(notes),
      'remind': serializer.toJson<bool>(remind),
    };
  }

  LendingRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    LendingDirection? direction,
    String? person,
    int? amountPaise,
    DateTime? givenOn,
    Value<DateTime?> dueOn = const Value.absent(),
    LendingStatus? status,
    Value<DateTime?> completedOn = const Value.absent(),
    String? notes,
    bool? remind,
  }) => LendingRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    direction: direction ?? this.direction,
    person: person ?? this.person,
    amountPaise: amountPaise ?? this.amountPaise,
    givenOn: givenOn ?? this.givenOn,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
    status: status ?? this.status,
    completedOn: completedOn.present ? completedOn.value : this.completedOn,
    notes: notes ?? this.notes,
    remind: remind ?? this.remind,
  );
  LendingRow copyWithCompanion(LendingRecordsCompanion data) {
    return LendingRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      direction: data.direction.present ? data.direction.value : this.direction,
      person: data.person.present ? data.person.value : this.person,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      givenOn: data.givenOn.present ? data.givenOn.value : this.givenOn,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      status: data.status.present ? data.status.value : this.status,
      completedOn: data.completedOn.present
          ? data.completedOn.value
          : this.completedOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      remind: data.remind.present ? data.remind.value : this.remind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LendingRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('direction: $direction, ')
          ..write('person: $person, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('givenOn: $givenOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('status: $status, ')
          ..write('completedOn: $completedOn, ')
          ..write('notes: $notes, ')
          ..write('remind: $remind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    direction,
    person,
    amountPaise,
    givenOn,
    dueOn,
    status,
    completedOn,
    notes,
    remind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LendingRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.direction == this.direction &&
          other.person == this.person &&
          other.amountPaise == this.amountPaise &&
          other.givenOn == this.givenOn &&
          other.dueOn == this.dueOn &&
          other.status == this.status &&
          other.completedOn == this.completedOn &&
          other.notes == this.notes &&
          other.remind == this.remind);
}

class LendingRecordsCompanion extends UpdateCompanion<LendingRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<LendingDirection> direction;
  final Value<String> person;
  final Value<int> amountPaise;
  final Value<DateTime> givenOn;
  final Value<DateTime?> dueOn;
  final Value<LendingStatus> status;
  final Value<DateTime?> completedOn;
  final Value<String> notes;
  final Value<bool> remind;
  final Value<int> rowid;
  const LendingRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.direction = const Value.absent(),
    this.person = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.givenOn = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.status = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.remind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LendingRecordsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required LendingDirection direction,
    required String person,
    required int amountPaise,
    required DateTime givenOn,
    this.dueOn = const Value.absent(),
    required LendingStatus status,
    this.completedOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.remind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       direction = Value(direction),
       person = Value(person),
       amountPaise = Value(amountPaise),
       givenOn = Value(givenOn),
       status = Value(status);
  static Insertable<LendingRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? direction,
    Expression<String>? person,
    Expression<int>? amountPaise,
    Expression<String>? givenOn,
    Expression<String>? dueOn,
    Expression<String>? status,
    Expression<String>? completedOn,
    Expression<String>? notes,
    Expression<bool>? remind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (direction != null) 'direction': direction,
      if (person != null) 'person': person,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (givenOn != null) 'given_on': givenOn,
      if (dueOn != null) 'due_on': dueOn,
      if (status != null) 'status': status,
      if (completedOn != null) 'completed_on': completedOn,
      if (notes != null) 'notes': notes,
      if (remind != null) 'remind': remind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LendingRecordsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<LendingDirection>? direction,
    Value<String>? person,
    Value<int>? amountPaise,
    Value<DateTime>? givenOn,
    Value<DateTime?>? dueOn,
    Value<LendingStatus>? status,
    Value<DateTime?>? completedOn,
    Value<String>? notes,
    Value<bool>? remind,
    Value<int>? rowid,
  }) {
    return LendingRecordsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      direction: direction ?? this.direction,
      person: person ?? this.person,
      amountPaise: amountPaise ?? this.amountPaise,
      givenOn: givenOn ?? this.givenOn,
      dueOn: dueOn ?? this.dueOn,
      status: status ?? this.status,
      completedOn: completedOn ?? this.completedOn,
      notes: notes ?? this.notes,
      remind: remind ?? this.remind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $LendingRecordsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (givenOn.present) {
      map['given_on'] = Variable<String>(
        $LendingRecordsTable.$convertergivenOn.toSql(givenOn.value),
      );
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(
        $LendingRecordsTable.$converterdueOnn.toSql(dueOn.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $LendingRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (completedOn.present) {
      map['completed_on'] = Variable<String>(
        $LendingRecordsTable.$convertercompletedOnn.toSql(completedOn.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (remind.present) {
      map['remind'] = Variable<bool>(remind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LendingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('direction: $direction, ')
          ..write('person: $person, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('givenOn: $givenOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('status: $status, ')
          ..write('completedOn: $completedOn, ')
          ..write('notes: $notes, ')
          ..write('remind: $remind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, MedicineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<TimeOfDayMinutes>, String>
  times = GeneratedColumn<String>(
    'times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<TimeOfDayMinutes>>($MedicinesTable.$convertertimes);
  @override
  late final GeneratedColumnWithTypeConverter<Set<int>, String> weekdays =
      GeneratedColumn<String>(
        'weekdays',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      ).withConverter<Set<int>>($MedicinesTable.$converterweekdays);
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    times,
    weekdays,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      times: $MedicinesTable.$convertertimes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}times'],
        )!,
      ),
      weekdays: $MedicinesTable.$converterweekdays.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weekdays'],
        )!,
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<TimeOfDayMinutes>, String> $convertertimes =
      const TimesConverter();
  static TypeConverter<Set<int>, String> $converterweekdays =
      const WeekdaysConverter();
}

class MedicineRow extends DataClass implements Insertable<MedicineRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final List<TimeOfDayMinutes> times;
  final Set<int> weekdays;
  final bool enabled;
  const MedicineRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.times,
    required this.weekdays,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    {
      map['times'] = Variable<String>(
        $MedicinesTable.$convertertimes.toSql(times),
      );
    }
    {
      map['weekdays'] = Variable<String>(
        $MedicinesTable.$converterweekdays.toSql(weekdays),
      );
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      times: Value(times),
      weekdays: Value(weekdays),
      enabled: Value(enabled),
    );
  }

  factory MedicineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      times: serializer.fromJson<List<TimeOfDayMinutes>>(json['times']),
      weekdays: serializer.fromJson<Set<int>>(json['weekdays']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'times': serializer.toJson<List<TimeOfDayMinutes>>(times),
      'weekdays': serializer.toJson<Set<int>>(weekdays),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  MedicineRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    List<TimeOfDayMinutes>? times,
    Set<int>? weekdays,
    bool? enabled,
  }) => MedicineRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    times: times ?? this.times,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
  );
  MedicineRow copyWithCompanion(MedicinesCompanion data) {
    return MedicineRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      times: data.times.present ? data.times.value : this.times,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('times: $times, ')
          ..write('weekdays: $weekdays, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, name, times, weekdays, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.times == this.times &&
          other.weekdays == this.weekdays &&
          other.enabled == this.enabled);
}

class MedicinesCompanion extends UpdateCompanion<MedicineRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<List<TimeOfDayMinutes>> times;
  final Value<Set<int>> weekdays;
  final Value<bool> enabled;
  final Value<int> rowid;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.times = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String name,
    required List<TimeOfDayMinutes> times,
    this.weekdays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       times = Value(times);
  static Insertable<MedicineRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? times,
    Expression<String>? weekdays,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (times != null) 'times': times,
      if (weekdays != null) 'weekdays': weekdays,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<List<TimeOfDayMinutes>>? times,
    Value<Set<int>>? weekdays,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      times: times ?? this.times,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (times.present) {
      map['times'] = Variable<String>(
        $MedicinesTable.$convertertimes.toSql(times.value),
      );
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(
        $MedicinesTable.$converterweekdays.toSql(weekdays.value),
      );
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('times: $times, ')
          ..write('weekdays: $weekdays, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShoppingListsTable shoppingLists = $ShoppingListsTable(this);
  late final Index shoppingOneActive = Index(
    'shopping_one_active',
    'CREATE UNIQUE INDEX shopping_one_active ON shopping_lists (status) WHERE status = \'active\'',
  );
  late final $ShoppingItemsTable shoppingItems = $ShoppingItemsTable(this);
  late final Index shoppingItemsList = Index(
    'shopping_items_list',
    'CREATE INDEX shopping_items_list ON shopping_items (list_id, position)',
  );
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final Index documentsExpiry = Index(
    'documents_expiry',
    'CREATE INDEX documents_expiry ON documents (expiry_date)',
  );
  late final DocumentsFts documentsFts = DocumentsFts(this);
  late final Trigger documentsFtsAi = Trigger(
    'CREATE TRIGGER documents_fts_ai AFTER INSERT ON documents BEGIN INSERT INTO documents_fts ("rowid", title, description, original_name) VALUES (new."rowid", new.title, new.description, new.original_name);END',
    'documents_fts_ai',
  );
  late final Trigger documentsFtsAd = Trigger(
    'CREATE TRIGGER documents_fts_ad AFTER DELETE ON documents BEGIN INSERT INTO documents_fts (documents_fts, "rowid", title, description, original_name) VALUES (\'delete\', old."rowid", old.title, old.description, old.original_name);END',
    'documents_fts_ad',
  );
  late final Trigger documentsFtsAu = Trigger(
    'CREATE TRIGGER documents_fts_au AFTER UPDATE ON documents BEGIN INSERT INTO documents_fts (documents_fts, "rowid", title, description, original_name) VALUES (\'delete\', old."rowid", old.title, old.description, old.original_name);INSERT INTO documents_fts ("rowid", title, description, original_name) VALUES (new."rowid", new.title, new.description, new.original_name);END',
    'documents_fts_au',
  );
  late final $PasswordNotesTable passwordNotes = $PasswordNotesTable(this);
  late final PasswordNotesFts passwordNotesFts = PasswordNotesFts(this);
  late final Trigger passwordFtsAi = Trigger(
    'CREATE TRIGGER password_fts_ai AFTER INSERT ON password_notes BEGIN INSERT INTO password_notes_fts ("rowid", name, url, username) VALUES (new."rowid", new.name, new.url, new.username);END',
    'password_fts_ai',
  );
  late final Trigger passwordFtsAd = Trigger(
    'CREATE TRIGGER password_fts_ad AFTER DELETE ON password_notes BEGIN INSERT INTO password_notes_fts (password_notes_fts, "rowid", name, url, username) VALUES (\'delete\', old."rowid", old.name, old.url, old.username);END',
    'password_fts_ad',
  );
  late final Trigger passwordFtsAu = Trigger(
    'CREATE TRIGGER password_fts_au AFTER UPDATE ON password_notes BEGIN INSERT INTO password_notes_fts (password_notes_fts, "rowid", name, url, username) VALUES (\'delete\', old."rowid", old.name, old.url, old.username);INSERT INTO password_notes_fts ("rowid", name, url, username) VALUES (new."rowid", new.name, new.url, new.username);END',
    'password_fts_au',
  );
  late final $PersonalEntriesTable personalEntries = $PersonalEntriesTable(
    this,
  );
  late final PersonalEntriesFts personalEntriesFts = PersonalEntriesFts(this);
  late final Trigger personalFtsAi = Trigger(
    'CREATE TRIGGER personal_fts_ai AFTER INSERT ON personal_entries BEGIN INSERT INTO personal_entries_fts ("rowid", title, search_text) VALUES (new."rowid", new.title, new.search_text);END',
    'personal_fts_ai',
  );
  late final Trigger personalFtsAd = Trigger(
    'CREATE TRIGGER personal_fts_ad AFTER DELETE ON personal_entries BEGIN INSERT INTO personal_entries_fts (personal_entries_fts, "rowid", title, search_text) VALUES (\'delete\', old."rowid", old.title, old.search_text);END',
    'personal_fts_ad',
  );
  late final Trigger personalFtsAu = Trigger(
    'CREATE TRIGGER personal_fts_au AFTER UPDATE ON personal_entries BEGIN INSERT INTO personal_entries_fts (personal_entries_fts, "rowid", title, search_text) VALUES (\'delete\', old."rowid", old.title, old.search_text);INSERT INTO personal_entries_fts ("rowid", title, search_text) VALUES (new."rowid", new.title, new.search_text);END',
    'personal_fts_au',
  );
  late final $NotesTable notes = $NotesTable(this);
  late final NotesFts notesFts = NotesFts(this);
  late final Trigger notesFtsAi = Trigger(
    'CREATE TRIGGER notes_fts_ai AFTER INSERT ON notes BEGIN INSERT INTO notes_fts ("rowid", title, plain_text, tags) VALUES (new."rowid", new.title, new.plain_text, new.tags);END',
    'notes_fts_ai',
  );
  late final Trigger notesFtsAd = Trigger(
    'CREATE TRIGGER notes_fts_ad AFTER DELETE ON notes BEGIN INSERT INTO notes_fts (notes_fts, "rowid", title, plain_text, tags) VALUES (\'delete\', old."rowid", old.title, old.plain_text, old.tags);END',
    'notes_fts_ad',
  );
  late final Trigger notesFtsAu = Trigger(
    'CREATE TRIGGER notes_fts_au AFTER UPDATE ON notes BEGIN INSERT INTO notes_fts (notes_fts, "rowid", title, plain_text, tags) VALUES (\'delete\', old."rowid", old.title, old.plain_text, old.tags);INSERT INTO notes_fts ("rowid", title, plain_text, tags) VALUES (new."rowid", new.title, new.plain_text, new.tags);END',
    'notes_fts_au',
  );
  late final $NoteAttachmentsTable noteAttachments = $NoteAttachmentsTable(
    this,
  );
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskChecklistItemsTable taskChecklistItems =
      $TaskChecklistItemsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $BudgetAmountsTable budgetAmounts = $BudgetAmountsTable(this);
  late final $LendingRecordsTable lendingRecords = $LendingRecordsTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shoppingLists,
    shoppingOneActive,
    shoppingItems,
    shoppingItemsList,
    documents,
    documentsExpiry,
    documentsFts,
    documentsFtsAi,
    documentsFtsAd,
    documentsFtsAu,
    passwordNotes,
    passwordNotesFts,
    passwordFtsAi,
    passwordFtsAd,
    passwordFtsAu,
    personalEntries,
    personalEntriesFts,
    personalFtsAi,
    personalFtsAd,
    personalFtsAu,
    notes,
    notesFts,
    notesFtsAi,
    notesFtsAd,
    notesFtsAu,
    noteAttachments,
    tasks,
    taskChecklistItems,
    reminders,
    expenses,
    budgetAmounts,
    lendingRecords,
    medicines,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('documents_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('documents_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('documents_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'password_notes',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('password_notes_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'password_notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('password_notes_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'password_notes',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('password_notes_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'personal_entries',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('personal_entries_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'personal_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('personal_entries_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'personal_entries',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('personal_entries_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('notes_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notes_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('notes_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_checklist_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ShoppingListsTableCreateCompanionBuilder =
    ShoppingListsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String name,
      required ShoppingListStatus status,
      Value<String?> copiedFromId,
      Value<DateTime?> startedAt,
      Value<DateTime?> pausedAt,
      Value<DateTime?> purchasedOn,
      Value<int?> totalPaise,
      Value<String> store,
      Value<PaymentMethod?> paymentMethod,
      Value<String?> receiptKey,
      Value<String?> receiptName,
      Value<SupportedFileType?> receiptType,
      Value<int> rowid,
    });
typedef $$ShoppingListsTableUpdateCompanionBuilder =
    ShoppingListsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> name,
      Value<ShoppingListStatus> status,
      Value<String?> copiedFromId,
      Value<DateTime?> startedAt,
      Value<DateTime?> pausedAt,
      Value<DateTime?> purchasedOn,
      Value<int?> totalPaise,
      Value<String> store,
      Value<PaymentMethod?> paymentMethod,
      Value<String?> receiptKey,
      Value<String?> receiptName,
      Value<SupportedFileType?> receiptType,
      Value<int> rowid,
    });

final class $$ShoppingListsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShoppingListsTable, ShoppingListRow> {
  $$ShoppingListsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ShoppingItemsTable, List<ShoppingItemRow>>
  _shoppingItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shoppingItems,
    aliasName: 'shopping_lists__id__shopping_items__list_id',
  );

  $$ShoppingItemsTableProcessedTableManager get shoppingItemsRefs {
    final manager = $$ShoppingItemsTableTableManager(
      $_db,
      $_db.shoppingItems,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shoppingItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShoppingListsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ShoppingListStatus, ShoppingListStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get copiedFromId => $composableBuilder(
    column: $table.copiedFromId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get purchasedOn =>
      $composableBuilder(
        column: $table.purchasedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get store => $composableBuilder(
    column: $table.store,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get receiptKey => $composableBuilder(
    column: $table.receiptKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptName => $composableBuilder(
    column: $table.receiptName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SupportedFileType?, SupportedFileType, String>
  get receiptType => $composableBuilder(
    column: $table.receiptType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> shoppingItemsRefs(
    Expression<bool> Function($$ShoppingItemsTableFilterComposer f) f,
  ) {
    final $$ShoppingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableFilterComposer(
            $db: $db,
            $table: $db.shoppingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShoppingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get copiedFromId => $composableBuilder(
    column: $table.copiedFromId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchasedOn => $composableBuilder(
    column: $table.purchasedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get store => $composableBuilder(
    column: $table.store,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptKey => $composableBuilder(
    column: $table.receiptKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptName => $composableBuilder(
    column: $table.receiptName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptType => $composableBuilder(
    column: $table.receiptType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoppingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ShoppingListStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get copiedFromId => $composableBuilder(
    column: $table.copiedFromId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get purchasedOn =>
      $composableBuilder(
        column: $table.purchasedOn,
        builder: (column) => column,
      );

  GeneratedColumn<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod?, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get receiptKey => $composableBuilder(
    column: $table.receiptKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptName => $composableBuilder(
    column: $table.receiptName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SupportedFileType?, String>
  get receiptType => $composableBuilder(
    column: $table.receiptType,
    builder: (column) => column,
  );

  Expression<T> shoppingItemsRefs<T extends Object>(
    Expression<T> Function($$ShoppingItemsTableAnnotationComposer a) f,
  ) {
    final $$ShoppingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.shoppingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShoppingListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingListsTable,
          ShoppingListRow,
          $$ShoppingListsTableFilterComposer,
          $$ShoppingListsTableOrderingComposer,
          $$ShoppingListsTableAnnotationComposer,
          $$ShoppingListsTableCreateCompanionBuilder,
          $$ShoppingListsTableUpdateCompanionBuilder,
          (ShoppingListRow, $$ShoppingListsTableReferences),
          ShoppingListRow,
          PrefetchHooks Function({bool shoppingItemsRefs})
        > {
  $$ShoppingListsTableTableManager(_$AppDatabase db, $ShoppingListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ShoppingListStatus> status = const Value.absent(),
                Value<String?> copiedFromId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> purchasedOn = const Value.absent(),
                Value<int?> totalPaise = const Value.absent(),
                Value<String> store = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<String?> receiptKey = const Value.absent(),
                Value<String?> receiptName = const Value.absent(),
                Value<SupportedFileType?> receiptType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingListsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                status: status,
                copiedFromId: copiedFromId,
                startedAt: startedAt,
                pausedAt: pausedAt,
                purchasedOn: purchasedOn,
                totalPaise: totalPaise,
                store: store,
                paymentMethod: paymentMethod,
                receiptKey: receiptKey,
                receiptName: receiptName,
                receiptType: receiptType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String name,
                required ShoppingListStatus status,
                Value<String?> copiedFromId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> purchasedOn = const Value.absent(),
                Value<int?> totalPaise = const Value.absent(),
                Value<String> store = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<String?> receiptKey = const Value.absent(),
                Value<String?> receiptName = const Value.absent(),
                Value<SupportedFileType?> receiptType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingListsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                status: status,
                copiedFromId: copiedFromId,
                startedAt: startedAt,
                pausedAt: pausedAt,
                purchasedOn: purchasedOn,
                totalPaise: totalPaise,
                store: store,
                paymentMethod: paymentMethod,
                receiptKey: receiptKey,
                receiptName: receiptName,
                receiptType: receiptType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoppingListsTable, ShoppingListRow>(table),
                  $$ShoppingListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shoppingItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shoppingItemsRefs) db.shoppingItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shoppingItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      ShoppingListRow,
                      $ShoppingListsTable,
                      ShoppingItemRow,
                      $ShoppingItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$ShoppingListsTableReferences
                          ._shoppingItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShoppingListsTableReferences(
                            db,
                            table,
                            p0,
                          ).shoppingItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'list_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShoppingListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingListsTable,
      ShoppingListRow,
      $$ShoppingListsTableFilterComposer,
      $$ShoppingListsTableOrderingComposer,
      $$ShoppingListsTableAnnotationComposer,
      $$ShoppingListsTableCreateCompanionBuilder,
      $$ShoppingListsTableUpdateCompanionBuilder,
      (ShoppingListRow, $$ShoppingListsTableReferences),
      ShoppingListRow,
      PrefetchHooks Function({bool shoppingItemsRefs})
    >;
typedef $$ShoppingItemsTableCreateCompanionBuilder =
    ShoppingItemsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String listId,
      required String name,
      Value<String> quantity,
      Value<String> unit,
      Value<bool> isPurchased,
      required int position,
      Value<int> rowid,
    });
typedef $$ShoppingItemsTableUpdateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> listId,
      Value<String> name,
      Value<String> quantity,
      Value<String> unit,
      Value<bool> isPurchased,
      Value<int> position,
      Value<int> rowid,
    });

final class $$ShoppingItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow> {
  $$ShoppingItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ShoppingListsTable _listIdTable(_$AppDatabase db) => db.shoppingLists
      .createAlias('shopping_items__list_id__shopping_lists__id');

  $$ShoppingListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<String>('list_id')!;

    final manager = $$ShoppingListsTableTableManager(
      $_db,
      $_db.shoppingLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$ShoppingListsTableFilterComposer get listId {
    final $$ShoppingListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.shoppingLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingListsTableFilterComposer(
            $db: $db,
            $table: $db.shoppingLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShoppingListsTableOrderingComposer get listId {
    final $$ShoppingListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.shoppingLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingListsTableOrderingComposer(
            $db: $db,
            $table: $db.shoppingLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$ShoppingListsTableAnnotationComposer get listId {
    final $$ShoppingListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.shoppingLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingListsTableAnnotationComposer(
            $db: $db,
            $table: $db.shoppingLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingItemsTable,
          ShoppingItemRow,
          $$ShoppingItemsTableFilterComposer,
          $$ShoppingItemsTableOrderingComposer,
          $$ShoppingItemsTableAnnotationComposer,
          $$ShoppingItemsTableCreateCompanionBuilder,
          $$ShoppingItemsTableUpdateCompanionBuilder,
          (ShoppingItemRow, $$ShoppingItemsTableReferences),
          ShoppingItemRow,
          PrefetchHooks Function({bool listId})
        > {
  $$ShoppingItemsTableTableManager(_$AppDatabase db, $ShoppingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> isPurchased = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                listId: listId,
                name: name,
                quantity: quantity,
                unit: unit,
                isPurchased: isPurchased,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String listId,
                required String name,
                Value<String> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> isPurchased = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                listId: listId,
                name: name,
                quantity: quantity,
                unit: unit,
                isPurchased: isPurchased,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoppingItemsTable, ShoppingItemRow>(table),
                  $$ShoppingItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
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
                    if (listId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.listId,
                        referencedTable: $$ShoppingItemsTableReferences
                            ._listIdTable(db),
                        referencedColumn: $$ShoppingItemsTableReferences
                            ._listIdTable(db)
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

typedef $$ShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingItemsTable,
      ShoppingItemRow,
      $$ShoppingItemsTableFilterComposer,
      $$ShoppingItemsTableOrderingComposer,
      $$ShoppingItemsTableAnnotationComposer,
      $$ShoppingItemsTableCreateCompanionBuilder,
      $$ShoppingItemsTableUpdateCompanionBuilder,
      (ShoppingItemRow, $$ShoppingItemsTableReferences),
      ShoppingItemRow,
      PrefetchHooks Function({bool listId})
    >;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String title,
  Value<String> description,
  required DocumentCategory category,
  required String fileKey,
  required String originalName,
  required SupportedFileType fileType,
  required int sizeBytes,
  Value<DateTime?> expiryDate,
  Value<bool> expiryReminder,
  Value<bool> isFavourite,
  Value<DriveStatus> driveStatus,
  Value<String?> driveFileId,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> title,
  Value<String> description,
  Value<DocumentCategory> category,
  Value<String> fileKey,
  Value<String> originalName,
  Value<SupportedFileType> fileType,
  Value<int> sizeBytes,
  Value<DateTime?> expiryDate,
  Value<bool> expiryReminder,
  Value<bool> isFavourite,
  Value<DriveStatus> driveStatus,
  Value<String?> driveFileId,
  Value<int> rowid,
});

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DocumentCategory, DocumentCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SupportedFileType, SupportedFileType, String>
  get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get expiryDate =>
      $composableBuilder(
        column: $table.expiryDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get expiryReminder => $composableBuilder(
    column: $table.expiryReminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DriveStatus, DriveStatus, String>
  get driveStatus => $composableBuilder(
    column: $table.driveStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get expiryReminder => $composableBuilder(
    column: $table.expiryReminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveStatus => $composableBuilder(
    column: $table.driveStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DocumentCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get fileKey =>
      $composableBuilder(column: $table.fileKey, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SupportedFileType, String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get expiryDate =>
      $composableBuilder(
        column: $table.expiryDate,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get expiryReminder => $composableBuilder(
    column: $table.expiryReminder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DriveStatus, String> get driveStatus =>
      $composableBuilder(
        column: $table.driveStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => column,
  );
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          DocumentRow,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (
            DocumentRow,
            BaseReferences<_$AppDatabase, $DocumentsTable, DocumentRow>,
          ),
          DocumentRow,
          PrefetchHooks Function()
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DocumentCategory> category = const Value.absent(),
                Value<String> fileKey = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<SupportedFileType> fileType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<bool> expiryReminder = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<DriveStatus> driveStatus = const Value.absent(),
                Value<String?> driveFileId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                category: category,
                fileKey: fileKey,
                originalName: originalName,
                fileType: fileType,
                sizeBytes: sizeBytes,
                expiryDate: expiryDate,
                expiryReminder: expiryReminder,
                isFavourite: isFavourite,
                driveStatus: driveStatus,
                driveFileId: driveFileId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String title,
                Value<String> description = const Value.absent(),
                required DocumentCategory category,
                required String fileKey,
                required String originalName,
                required SupportedFileType fileType,
                required int sizeBytes,
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<bool> expiryReminder = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<DriveStatus> driveStatus = const Value.absent(),
                Value<String?> driveFileId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                category: category,
                fileKey: fileKey,
                originalName: originalName,
                fileType: fileType,
                sizeBytes: sizeBytes,
                expiryDate: expiryDate,
                expiryReminder: expiryReminder,
                isFavourite: isFavourite,
                driveStatus: driveStatus,
                driveFileId: driveFileId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, DocumentRow>(table),
                  BaseReferences<_$AppDatabase, $DocumentsTable, DocumentRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      DocumentRow,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (
        DocumentRow,
        BaseReferences<_$AppDatabase, $DocumentsTable, DocumentRow>,
      ),
      DocumentRow,
      PrefetchHooks Function()
    >;
typedef $DocumentsFtsCreateCompanionBuilder = DocumentsFtsCompanion Function({
  required String title,
  required String description,
  required String originalName,
  Value<int> rowid,
});
typedef $DocumentsFtsUpdateCompanionBuilder = DocumentsFtsCompanion Function({
  Value<String> title,
  Value<String> description,
  Value<String> originalName,
  Value<int> rowid,
});

class $DocumentsFtsFilterComposer
    extends Composer<_$AppDatabase, DocumentsFts> {
  $DocumentsFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );
}

class $DocumentsFtsOrderingComposer
    extends Composer<_$AppDatabase, DocumentsFts> {
  $DocumentsFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DocumentsFtsAnnotationComposer
    extends Composer<_$AppDatabase, DocumentsFts> {
  $DocumentsFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );
}

class $DocumentsFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DocumentsFts,
          DocumentsFt,
          $DocumentsFtsFilterComposer,
          $DocumentsFtsOrderingComposer,
          $DocumentsFtsAnnotationComposer,
          $DocumentsFtsCreateCompanionBuilder,
          $DocumentsFtsUpdateCompanionBuilder,
          (
            DocumentsFt,
            BaseReferences<_$AppDatabase, DocumentsFts, DocumentsFt>,
          ),
          DocumentsFt,
          PrefetchHooks Function()
        > {
  $DocumentsFtsTableManager(_$AppDatabase db, DocumentsFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DocumentsFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DocumentsFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DocumentsFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsFtsCompanion(
                title: title,
                description: description,
                originalName: originalName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String description,
                required String originalName,
                Value<int> rowid = const Value.absent(),
              }) => DocumentsFtsCompanion.insert(
                title: title,
                description: description,
                originalName: originalName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DocumentsFts, DocumentsFt>(table),
                  BaseReferences<_$AppDatabase, DocumentsFts, DocumentsFt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DocumentsFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DocumentsFts,
      DocumentsFt,
      $DocumentsFtsFilterComposer,
      $DocumentsFtsOrderingComposer,
      $DocumentsFtsAnnotationComposer,
      $DocumentsFtsCreateCompanionBuilder,
      $DocumentsFtsUpdateCompanionBuilder,
      (DocumentsFt, BaseReferences<_$AppDatabase, DocumentsFts, DocumentsFt>),
      DocumentsFt,
      PrefetchHooks Function()
    >;
typedef $$PasswordNotesTableCreateCompanionBuilder =
    PasswordNotesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String name,
      Value<String> url,
      Value<String> username,
      Value<String> password,
      Value<String> notes,
      Value<String> category,
      Value<bool> isFavourite,
      Value<int> rowid,
    });
typedef $$PasswordNotesTableUpdateCompanionBuilder =
    PasswordNotesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> name,
      Value<String> url,
      Value<String> username,
      Value<String> password,
      Value<String> notes,
      Value<String> category,
      Value<bool> isFavourite,
      Value<int> rowid,
    });

class $$PasswordNotesTableFilterComposer
    extends Composer<_$AppDatabase, $PasswordNotesTable> {
  $$PasswordNotesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PasswordNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $PasswordNotesTable> {
  $$PasswordNotesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PasswordNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PasswordNotesTable> {
  $$PasswordNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );
}

class $$PasswordNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PasswordNotesTable,
          PasswordNoteRow,
          $$PasswordNotesTableFilterComposer,
          $$PasswordNotesTableOrderingComposer,
          $$PasswordNotesTableAnnotationComposer,
          $$PasswordNotesTableCreateCompanionBuilder,
          $$PasswordNotesTableUpdateCompanionBuilder,
          (
            PasswordNoteRow,
            BaseReferences<_$AppDatabase, $PasswordNotesTable, PasswordNoteRow>,
          ),
          PasswordNoteRow,
          PrefetchHooks Function()
        > {
  $$PasswordNotesTableTableManager(_$AppDatabase db, $PasswordNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PasswordNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PasswordNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PasswordNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PasswordNotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                url: url,
                username: username,
                password: password,
                notes: notes,
                category: category,
                isFavourite: isFavourite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String name,
                Value<String> url = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PasswordNotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                url: url,
                username: username,
                password: password,
                notes: notes,
                category: category,
                isFavourite: isFavourite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PasswordNotesTable, PasswordNoteRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PasswordNotesTable,
                    PasswordNoteRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PasswordNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PasswordNotesTable,
      PasswordNoteRow,
      $$PasswordNotesTableFilterComposer,
      $$PasswordNotesTableOrderingComposer,
      $$PasswordNotesTableAnnotationComposer,
      $$PasswordNotesTableCreateCompanionBuilder,
      $$PasswordNotesTableUpdateCompanionBuilder,
      (
        PasswordNoteRow,
        BaseReferences<_$AppDatabase, $PasswordNotesTable, PasswordNoteRow>,
      ),
      PasswordNoteRow,
      PrefetchHooks Function()
    >;
typedef $PasswordNotesFtsCreateCompanionBuilder =
    PasswordNotesFtsCompanion Function({
      required String name,
      required String url,
      required String username,
      Value<int> rowid,
    });
typedef $PasswordNotesFtsUpdateCompanionBuilder =
    PasswordNotesFtsCompanion Function({
      Value<String> name,
      Value<String> url,
      Value<String> username,
      Value<int> rowid,
    });

class $PasswordNotesFtsFilterComposer
    extends Composer<_$AppDatabase, PasswordNotesFts> {
  $PasswordNotesFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );
}

class $PasswordNotesFtsOrderingComposer
    extends Composer<_$AppDatabase, PasswordNotesFts> {
  $PasswordNotesFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PasswordNotesFtsAnnotationComposer
    extends Composer<_$AppDatabase, PasswordNotesFts> {
  $PasswordNotesFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);
}

class $PasswordNotesFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PasswordNotesFts,
          PasswordNotesFt,
          $PasswordNotesFtsFilterComposer,
          $PasswordNotesFtsOrderingComposer,
          $PasswordNotesFtsAnnotationComposer,
          $PasswordNotesFtsCreateCompanionBuilder,
          $PasswordNotesFtsUpdateCompanionBuilder,
          (
            PasswordNotesFt,
            BaseReferences<_$AppDatabase, PasswordNotesFts, PasswordNotesFt>,
          ),
          PasswordNotesFt,
          PrefetchHooks Function()
        > {
  $PasswordNotesFtsTableManager(_$AppDatabase db, PasswordNotesFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PasswordNotesFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PasswordNotesFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PasswordNotesFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PasswordNotesFtsCompanion(
                name: name,
                url: url,
                username: username,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String url,
                required String username,
                Value<int> rowid = const Value.absent(),
              }) => PasswordNotesFtsCompanion.insert(
                name: name,
                url: url,
                username: username,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PasswordNotesFts, PasswordNotesFt>(table),
                  BaseReferences<
                    _$AppDatabase,
                    PasswordNotesFts,
                    PasswordNotesFt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PasswordNotesFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PasswordNotesFts,
      PasswordNotesFt,
      $PasswordNotesFtsFilterComposer,
      $PasswordNotesFtsOrderingComposer,
      $PasswordNotesFtsAnnotationComposer,
      $PasswordNotesFtsCreateCompanionBuilder,
      $PasswordNotesFtsUpdateCompanionBuilder,
      (
        PasswordNotesFt,
        BaseReferences<_$AppDatabase, PasswordNotesFts, PasswordNotesFt>,
      ),
      PasswordNotesFt,
      PrefetchHooks Function()
    >;
typedef $$PersonalEntriesTableCreateCompanionBuilder =
    PersonalEntriesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DetailKind kind,
      Value<String> title,
      required List<DetailField> fieldsJson,
      Value<String> searchText,
      Value<List<String>> linkedDocumentIds,
      Value<int> rowid,
    });
typedef $$PersonalEntriesTableUpdateCompanionBuilder =
    PersonalEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DetailKind> kind,
      Value<String> title,
      Value<List<DetailField>> fieldsJson,
      Value<String> searchText,
      Value<List<String>> linkedDocumentIds,
      Value<int> rowid,
    });

class $$PersonalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalEntriesTable> {
  $$PersonalEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DetailKind, DetailKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<DetailField>, List<DetailField>, String>
  get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get linkedDocumentIds => $composableBuilder(
    column: $table.linkedDocumentIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$PersonalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalEntriesTable> {
  $$PersonalEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedDocumentIds => $composableBuilder(
    column: $table.linkedDocumentIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalEntriesTable> {
  $$PersonalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DetailKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<DetailField>, String> get fieldsJson =>
      $composableBuilder(
        column: $table.fieldsJson,
        builder: (column) => column,
      );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String>
  get linkedDocumentIds => $composableBuilder(
    column: $table.linkedDocumentIds,
    builder: (column) => column,
  );
}

class $$PersonalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalEntriesTable,
          PersonalEntryRow,
          $$PersonalEntriesTableFilterComposer,
          $$PersonalEntriesTableOrderingComposer,
          $$PersonalEntriesTableAnnotationComposer,
          $$PersonalEntriesTableCreateCompanionBuilder,
          $$PersonalEntriesTableUpdateCompanionBuilder,
          (
            PersonalEntryRow,
            BaseReferences<
              _$AppDatabase,
              $PersonalEntriesTable,
              PersonalEntryRow
            >,
          ),
          PersonalEntryRow,
          PrefetchHooks Function()
        > {
  $$PersonalEntriesTableTableManager(
    _$AppDatabase db,
    $PersonalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DetailKind> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<List<DetailField>> fieldsJson = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<List<String>> linkedDocumentIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                kind: kind,
                title: title,
                fieldsJson: fieldsJson,
                searchText: searchText,
                linkedDocumentIds: linkedDocumentIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DetailKind kind,
                Value<String> title = const Value.absent(),
                required List<DetailField> fieldsJson,
                Value<String> searchText = const Value.absent(),
                Value<List<String>> linkedDocumentIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                kind: kind,
                title: title,
                fieldsJson: fieldsJson,
                searchText: searchText,
                linkedDocumentIds: linkedDocumentIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonalEntriesTable, PersonalEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PersonalEntriesTable,
                    PersonalEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalEntriesTable,
      PersonalEntryRow,
      $$PersonalEntriesTableFilterComposer,
      $$PersonalEntriesTableOrderingComposer,
      $$PersonalEntriesTableAnnotationComposer,
      $$PersonalEntriesTableCreateCompanionBuilder,
      $$PersonalEntriesTableUpdateCompanionBuilder,
      (
        PersonalEntryRow,
        BaseReferences<_$AppDatabase, $PersonalEntriesTable, PersonalEntryRow>,
      ),
      PersonalEntryRow,
      PrefetchHooks Function()
    >;
typedef $PersonalEntriesFtsCreateCompanionBuilder =
    PersonalEntriesFtsCompanion Function({
      required String title,
      required String searchText,
      Value<int> rowid,
    });
typedef $PersonalEntriesFtsUpdateCompanionBuilder =
    PersonalEntriesFtsCompanion Function({
      Value<String> title,
      Value<String> searchText,
      Value<int> rowid,
    });

class $PersonalEntriesFtsFilterComposer
    extends Composer<_$AppDatabase, PersonalEntriesFts> {
  $PersonalEntriesFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );
}

class $PersonalEntriesFtsOrderingComposer
    extends Composer<_$AppDatabase, PersonalEntriesFts> {
  $PersonalEntriesFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PersonalEntriesFtsAnnotationComposer
    extends Composer<_$AppDatabase, PersonalEntriesFts> {
  $PersonalEntriesFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );
}

class $PersonalEntriesFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PersonalEntriesFts,
          PersonalEntriesFt,
          $PersonalEntriesFtsFilterComposer,
          $PersonalEntriesFtsOrderingComposer,
          $PersonalEntriesFtsAnnotationComposer,
          $PersonalEntriesFtsCreateCompanionBuilder,
          $PersonalEntriesFtsUpdateCompanionBuilder,
          (
            PersonalEntriesFt,
            BaseReferences<
              _$AppDatabase,
              PersonalEntriesFts,
              PersonalEntriesFt
            >,
          ),
          PersonalEntriesFt,
          PrefetchHooks Function()
        > {
  $PersonalEntriesFtsTableManager(_$AppDatabase db, PersonalEntriesFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PersonalEntriesFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PersonalEntriesFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PersonalEntriesFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalEntriesFtsCompanion(
                title: title,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String searchText,
                Value<int> rowid = const Value.absent(),
              }) => PersonalEntriesFtsCompanion.insert(
                title: title,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PersonalEntriesFts, PersonalEntriesFt>(table),
                  BaseReferences<
                    _$AppDatabase,
                    PersonalEntriesFts,
                    PersonalEntriesFt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PersonalEntriesFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PersonalEntriesFts,
      PersonalEntriesFt,
      $PersonalEntriesFtsFilterComposer,
      $PersonalEntriesFtsOrderingComposer,
      $PersonalEntriesFtsAnnotationComposer,
      $PersonalEntriesFtsCreateCompanionBuilder,
      $PersonalEntriesFtsUpdateCompanionBuilder,
      (
        PersonalEntriesFt,
        BaseReferences<_$AppDatabase, PersonalEntriesFts, PersonalEntriesFt>,
      ),
      PersonalEntriesFt,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> title,
  required String contentJson,
  Value<String> plainText,
  Value<String> tags,
  Value<bool> isPinned,
  Value<bool> isFavourite,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> title,
  Value<String> contentJson,
  Value<String> plainText,
  Value<String> tags,
  Value<bool> isPinned,
  Value<bool> isFavourite,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteAttachmentsTable, List<NoteAttachmentRow>>
  _noteAttachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteAttachments,
    aliasName: 'notes__id__note_attachments__note_id',
  );

  $$NoteAttachmentsTableProcessedTableManager get noteAttachmentsRefs {
    final manager = $$NoteAttachmentsTableTableManager(
      $_db,
      $_db.noteAttachments,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _noteAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteAttachmentsRefs(
    Expression<bool> Function($$NoteAttachmentsTableFilterComposer f) f,
  ) {
    final $$NoteAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteAttachments,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.noteAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> noteAttachmentsRefs<T extends Object>(
    Expression<T> Function($$NoteAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$NoteAttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteAttachments,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteAttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool noteAttachmentsRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> contentJson = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                contentJson: contentJson,
                plainText: plainText,
                tags: tags,
                isPinned: isPinned,
                isFavourite: isFavourite,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> title = const Value.absent(),
                required String contentJson,
                Value<String> plainText = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                contentJson: contentJson,
                plainText: plainText,
                tags: tags,
                isPinned: isPinned,
                isFavourite: isFavourite,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (noteAttachmentsRefs) db.noteAttachments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (noteAttachmentsRefs)
                    await $_getPrefetchedDataByColumns<
                      NoteRow,
                      $NotesTable,
                      NoteAttachmentRow,
                      $NoteAttachmentsTable
                    >(
                      currentTable: table,
                      referencedTable: $$NotesTableReferences
                          ._noteAttachmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$NotesTableReferences(
                        db,
                        table,
                        p0,
                      ).noteAttachmentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'note_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool noteAttachmentsRefs})
    >;
typedef $NotesFtsCreateCompanionBuilder = NotesFtsCompanion Function({
  required String title,
  required String plainText,
  required String tags,
  Value<int> rowid,
});
typedef $NotesFtsUpdateCompanionBuilder = NotesFtsCompanion Function({
  Value<String> title,
  Value<String> plainText,
  Value<String> tags,
  Value<int> rowid,
});

class $NotesFtsFilterComposer extends Composer<_$AppDatabase, NotesFts> {
  $NotesFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );
}

class $NotesFtsOrderingComposer extends Composer<_$AppDatabase, NotesFts> {
  $NotesFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $NotesFtsAnnotationComposer extends Composer<_$AppDatabase, NotesFts> {
  $NotesFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $NotesFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          NotesFts,
          NotesFt,
          $NotesFtsFilterComposer,
          $NotesFtsOrderingComposer,
          $NotesFtsAnnotationComposer,
          $NotesFtsCreateCompanionBuilder,
          $NotesFtsUpdateCompanionBuilder,
          (NotesFt, BaseReferences<_$AppDatabase, NotesFts, NotesFt>),
          NotesFt,
          PrefetchHooks Function()
        > {
  $NotesFtsTableManager(_$AppDatabase db, NotesFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $NotesFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $NotesFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $NotesFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesFtsCompanion(
                title: title,
                plainText: plainText,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String plainText,
                required String tags,
                Value<int> rowid = const Value.absent(),
              }) => NotesFtsCompanion.insert(
                title: title,
                plainText: plainText,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<NotesFts, NotesFt>(table),
                  BaseReferences<_$AppDatabase, NotesFts, NotesFt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $NotesFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      NotesFts,
      NotesFt,
      $NotesFtsFilterComposer,
      $NotesFtsOrderingComposer,
      $NotesFtsAnnotationComposer,
      $NotesFtsCreateCompanionBuilder,
      $NotesFtsUpdateCompanionBuilder,
      (NotesFt, BaseReferences<_$AppDatabase, NotesFts, NotesFt>),
      NotesFt,
      PrefetchHooks Function()
    >;
typedef $$NoteAttachmentsTableCreateCompanionBuilder =
    NoteAttachmentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String noteId,
      required String fileKey,
      required String originalName,
      required String mimeType,
      required int sizeBytes,
      Value<int> rowid,
    });
typedef $$NoteAttachmentsTableUpdateCompanionBuilder =
    NoteAttachmentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> noteId,
      Value<String> fileKey,
      Value<String> originalName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<int> rowid,
    });

final class $$NoteAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NoteAttachmentsTable,
          NoteAttachmentRow
        > {
  $$NoteAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_attachments__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteAttachmentsTable> {
  $$NoteAttachmentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteAttachmentsTable> {
  $$NoteAttachmentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteAttachmentsTable> {
  $$NoteAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get fileKey =>
      $composableBuilder(column: $table.fileKey, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteAttachmentsTable,
          NoteAttachmentRow,
          $$NoteAttachmentsTableFilterComposer,
          $$NoteAttachmentsTableOrderingComposer,
          $$NoteAttachmentsTableAnnotationComposer,
          $$NoteAttachmentsTableCreateCompanionBuilder,
          $$NoteAttachmentsTableUpdateCompanionBuilder,
          (NoteAttachmentRow, $$NoteAttachmentsTableReferences),
          NoteAttachmentRow,
          PrefetchHooks Function({bool noteId})
        > {
  $$NoteAttachmentsTableTableManager(
    _$AppDatabase db,
    $NoteAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> fileKey = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteAttachmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                noteId: noteId,
                fileKey: fileKey,
                originalName: originalName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String noteId,
                required String fileKey,
                required String originalName,
                required String mimeType,
                required int sizeBytes,
                Value<int> rowid = const Value.absent(),
              }) => NoteAttachmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                noteId: noteId,
                fileKey: fileKey,
                originalName: originalName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteAttachmentsTable, NoteAttachmentRow>(table),
                  $$NoteAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false}) {
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
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$NoteAttachmentsTableReferences
                            ._noteIdTable(db),
                        referencedColumn: $$NoteAttachmentsTableReferences
                            ._noteIdTable(db)
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

typedef $$NoteAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteAttachmentsTable,
      NoteAttachmentRow,
      $$NoteAttachmentsTableFilterComposer,
      $$NoteAttachmentsTableOrderingComposer,
      $$NoteAttachmentsTableAnnotationComposer,
      $$NoteAttachmentsTableCreateCompanionBuilder,
      $$NoteAttachmentsTableUpdateCompanionBuilder,
      (NoteAttachmentRow, $$NoteAttachmentsTableReferences),
      NoteAttachmentRow,
      PrefetchHooks Function({bool noteId})
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String title,
  Value<String> description,
  Value<DateTime?> dueDate,
  Value<DateTime?> reminderAt,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> title,
  Value<String> description,
  Value<DateTime?> dueDate,
  Value<DateTime?> reminderAt,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskRow> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskChecklistItemsTable, List<ChecklistItemRow>>
  _taskChecklistItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.taskChecklistItems,
        aliasName: 'tasks__id__task_checklist_items__task_id',
      );

  $$TaskChecklistItemsTableProcessedTableManager get taskChecklistItemsRefs {
    final manager = $$TaskChecklistItemsTableTableManager(
      $_db,
      $_db.taskChecklistItems,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskChecklistItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get dueDate =>
      $composableBuilder(
        column: $table.dueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get reminderAt =>
      $composableBuilder(
        column: $table.reminderAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> taskChecklistItemsRefs(
    Expression<bool> Function($$TaskChecklistItemsTableFilterComposer f) f,
  ) {
    final $$TaskChecklistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskChecklistItems,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskChecklistItemsTableFilterComposer(
            $db: $db,
            $table: $db.taskChecklistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get reminderAt =>
      $composableBuilder(
        column: $table.reminderAt,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> taskChecklistItemsRefs<T extends Object>(
    Expression<T> Function($$TaskChecklistItemsTableAnnotationComposer a) f,
  ) {
    final $$TaskChecklistItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskChecklistItems,
          getReferencedColumn: (t) => t.taskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskChecklistItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.taskChecklistItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, $$TasksTableReferences),
          TaskRow,
          PrefetchHooks Function({bool taskChecklistItemsRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                dueDate: dueDate,
                reminderAt: reminderAt,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String title,
                Value<String> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                dueDate: dueDate,
                reminderAt: reminderAt,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskChecklistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskChecklistItemsRefs) db.taskChecklistItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskChecklistItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      TaskRow,
                      $TasksTable,
                      ChecklistItemRow,
                      $TaskChecklistItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._taskChecklistItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TasksTableReferences(
                        db,
                        table,
                        p0,
                      ).taskChecklistItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'task_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, $$TasksTableReferences),
      TaskRow,
      PrefetchHooks Function({bool taskChecklistItemsRefs})
    >;
typedef $$TaskChecklistItemsTableCreateCompanionBuilder =
    TaskChecklistItemsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String taskId,
      required String label,
      Value<bool> isDone,
      required int position,
      Value<int> rowid,
    });
typedef $$TaskChecklistItemsTableUpdateCompanionBuilder =
    TaskChecklistItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> taskId,
      Value<String> label,
      Value<bool> isDone,
      Value<int> position,
      Value<int> rowid,
    });

final class $$TaskChecklistItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TaskChecklistItemsTable,
          ChecklistItemRow
        > {
  $$TaskChecklistItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_checklist_items__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskChecklistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskChecklistItemsTable> {
  $$TaskChecklistItemsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskChecklistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskChecklistItemsTable> {
  $$TaskChecklistItemsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskChecklistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskChecklistItemsTable> {
  $$TaskChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskChecklistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskChecklistItemsTable,
          ChecklistItemRow,
          $$TaskChecklistItemsTableFilterComposer,
          $$TaskChecklistItemsTableOrderingComposer,
          $$TaskChecklistItemsTableAnnotationComposer,
          $$TaskChecklistItemsTableCreateCompanionBuilder,
          $$TaskChecklistItemsTableUpdateCompanionBuilder,
          (ChecklistItemRow, $$TaskChecklistItemsTableReferences),
          ChecklistItemRow,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskChecklistItemsTableTableManager(
    _$AppDatabase db,
    $TaskChecklistItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskChecklistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskChecklistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskChecklistItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskChecklistItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                taskId: taskId,
                label: label,
                isDone: isDone,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String taskId,
                required String label,
                Value<bool> isDone = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => TaskChecklistItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                taskId: taskId,
                label: label,
                isDone: isDone,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskChecklistItemsTable, ChecklistItemRow>(
                    table,
                  ),
                  $$TaskChecklistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$TaskChecklistItemsTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$TaskChecklistItemsTableReferences
                            ._taskIdTable(db)
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

typedef $$TaskChecklistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskChecklistItemsTable,
      ChecklistItemRow,
      $$TaskChecklistItemsTableFilterComposer,
      $$TaskChecklistItemsTableOrderingComposer,
      $$TaskChecklistItemsTableAnnotationComposer,
      $$TaskChecklistItemsTableCreateCompanionBuilder,
      $$TaskChecklistItemsTableUpdateCompanionBuilder,
      (ChecklistItemRow, $$TaskChecklistItemsTableReferences),
      ChecklistItemRow,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String title,
  Value<String> description,
  required DateTime anchorAt,
  required DateTime dueAt,
  required RepeatFrequency repeat,
  Value<DateTime?> snoozedUntil,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> title,
  Value<String> description,
  Value<DateTime> anchorAt,
  Value<DateTime> dueAt,
  Value<RepeatFrequency> repeat,
  Value<DateTime?> snoozedUntil,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get anchorAt =>
      $composableBuilder(
        column: $table.anchorAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get dueAt =>
      $composableBuilder(
        column: $table.dueAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RepeatFrequency, RepeatFrequency, String>
  get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorAt => $composableBuilder(
    column: $table.anchorAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get anchorAt =>
      $composableBuilder(column: $table.anchorAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RepeatFrequency, String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get snoozedUntil =>
      $composableBuilder(
        column: $table.snoozedUntil,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> anchorAt = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<RepeatFrequency> repeat = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                anchorAt: anchorAt,
                dueAt: dueAt,
                repeat: repeat,
                snoozedUntil: snoozedUntil,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String title,
                Value<String> description = const Value.absent(),
                required DateTime anchorAt,
                required DateTime dueAt,
                required RepeatFrequency repeat,
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                anchorAt: anchorAt,
                dueAt: dueAt,
                repeat: repeat,
                snoozedUntil: snoozedUntil,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required int amountPaise,
  Value<String> description,
  required DateTime spentOn,
  required ExpenseSource source,
  Value<String?> sourceId,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> amountPaise,
  Value<String> description,
  Value<DateTime> spentOn,
  Value<ExpenseSource> source,
  Value<String?> sourceId,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get spentOn =>
      $composableBuilder(
        column: $table.spentOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ExpenseSource, ExpenseSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get spentOn =>
      $composableBuilder(column: $table.spentOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            ExpenseRow,
            BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>,
          ),
          ExpenseRow,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> spentOn = const Value.absent(),
                Value<ExpenseSource> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                amountPaise: amountPaise,
                description: description,
                spentOn: spentOn,
                source: source,
                sourceId: sourceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required int amountPaise,
                Value<String> description = const Value.absent(),
                required DateTime spentOn,
                required ExpenseSource source,
                Value<String?> sourceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                amountPaise: amountPaise,
                description: description,
                spentOn: spentOn,
                source: source,
                sourceId: sourceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>),
      ExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetAmountsTableCreateCompanionBuilder =
    BudgetAmountsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String fromMonth,
      required int amountPaise,
      Value<int> rowid,
    });
typedef $$BudgetAmountsTableUpdateCompanionBuilder =
    BudgetAmountsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> fromMonth,
      Value<int> amountPaise,
      Value<int> rowid,
    });

class $$BudgetAmountsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetAmountsTable> {
  $$BudgetAmountsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromMonth => $composableBuilder(
    column: $table.fromMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetAmountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetAmountsTable> {
  $$BudgetAmountsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromMonth => $composableBuilder(
    column: $table.fromMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetAmountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetAmountsTable> {
  $$BudgetAmountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get fromMonth =>
      $composableBuilder(column: $table.fromMonth, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );
}

class $$BudgetAmountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetAmountsTable,
          BudgetAmountRow,
          $$BudgetAmountsTableFilterComposer,
          $$BudgetAmountsTableOrderingComposer,
          $$BudgetAmountsTableAnnotationComposer,
          $$BudgetAmountsTableCreateCompanionBuilder,
          $$BudgetAmountsTableUpdateCompanionBuilder,
          (
            BudgetAmountRow,
            BaseReferences<_$AppDatabase, $BudgetAmountsTable, BudgetAmountRow>,
          ),
          BudgetAmountRow,
          PrefetchHooks Function()
        > {
  $$BudgetAmountsTableTableManager(_$AppDatabase db, $BudgetAmountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetAmountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetAmountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetAmountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> fromMonth = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetAmountsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fromMonth: fromMonth,
                amountPaise: amountPaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String fromMonth,
                required int amountPaise,
                Value<int> rowid = const Value.absent(),
              }) => BudgetAmountsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fromMonth: fromMonth,
                amountPaise: amountPaise,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetAmountsTable, BudgetAmountRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BudgetAmountsTable,
                    BudgetAmountRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetAmountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetAmountsTable,
      BudgetAmountRow,
      $$BudgetAmountsTableFilterComposer,
      $$BudgetAmountsTableOrderingComposer,
      $$BudgetAmountsTableAnnotationComposer,
      $$BudgetAmountsTableCreateCompanionBuilder,
      $$BudgetAmountsTableUpdateCompanionBuilder,
      (
        BudgetAmountRow,
        BaseReferences<_$AppDatabase, $BudgetAmountsTable, BudgetAmountRow>,
      ),
      BudgetAmountRow,
      PrefetchHooks Function()
    >;
typedef $$LendingRecordsTableCreateCompanionBuilder =
    LendingRecordsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required LendingDirection direction,
      required String person,
      required int amountPaise,
      required DateTime givenOn,
      Value<DateTime?> dueOn,
      required LendingStatus status,
      Value<DateTime?> completedOn,
      Value<String> notes,
      Value<bool> remind,
      Value<int> rowid,
    });
typedef $$LendingRecordsTableUpdateCompanionBuilder =
    LendingRecordsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<LendingDirection> direction,
      Value<String> person,
      Value<int> amountPaise,
      Value<DateTime> givenOn,
      Value<DateTime?> dueOn,
      Value<LendingStatus> status,
      Value<DateTime?> completedOn,
      Value<String> notes,
      Value<bool> remind,
      Value<int> rowid,
    });

class $$LendingRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LendingRecordsTable> {
  $$LendingRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LendingDirection, LendingDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get givenOn =>
      $composableBuilder(
        column: $table.givenOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get dueOn =>
      $composableBuilder(
        column: $table.dueOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LendingStatus, LendingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get completedOn =>
      $composableBuilder(
        column: $table.completedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remind => $composableBuilder(
    column: $table.remind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LendingRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LendingRecordsTable> {
  $$LendingRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenOn => $composableBuilder(
    column: $table.givenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remind => $composableBuilder(
    column: $table.remind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LendingRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LendingRecordsTable> {
  $$LendingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LendingDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get givenOn =>
      $composableBuilder(column: $table.givenOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LendingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get completedOn =>
      $composableBuilder(
        column: $table.completedOn,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => column);
}

class $$LendingRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LendingRecordsTable,
          LendingRow,
          $$LendingRecordsTableFilterComposer,
          $$LendingRecordsTableOrderingComposer,
          $$LendingRecordsTableAnnotationComposer,
          $$LendingRecordsTableCreateCompanionBuilder,
          $$LendingRecordsTableUpdateCompanionBuilder,
          (
            LendingRow,
            BaseReferences<_$AppDatabase, $LendingRecordsTable, LendingRow>,
          ),
          LendingRow,
          PrefetchHooks Function()
        > {
  $$LendingRecordsTableTableManager(
    _$AppDatabase db,
    $LendingRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LendingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LendingRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LendingRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<LendingDirection> direction = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> givenOn = const Value.absent(),
                Value<DateTime?> dueOn = const Value.absent(),
                Value<LendingStatus> status = const Value.absent(),
                Value<DateTime?> completedOn = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendingRecordsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                direction: direction,
                person: person,
                amountPaise: amountPaise,
                givenOn: givenOn,
                dueOn: dueOn,
                status: status,
                completedOn: completedOn,
                notes: notes,
                remind: remind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required LendingDirection direction,
                required String person,
                required int amountPaise,
                required DateTime givenOn,
                Value<DateTime?> dueOn = const Value.absent(),
                required LendingStatus status,
                Value<DateTime?> completedOn = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendingRecordsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                direction: direction,
                person: person,
                amountPaise: amountPaise,
                givenOn: givenOn,
                dueOn: dueOn,
                status: status,
                completedOn: completedOn,
                notes: notes,
                remind: remind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LendingRecordsTable, LendingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LendingRecordsTable,
                    LendingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LendingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LendingRecordsTable,
      LendingRow,
      $$LendingRecordsTableFilterComposer,
      $$LendingRecordsTableOrderingComposer,
      $$LendingRecordsTableAnnotationComposer,
      $$LendingRecordsTableCreateCompanionBuilder,
      $$LendingRecordsTableUpdateCompanionBuilder,
      (
        LendingRow,
        BaseReferences<_$AppDatabase, $LendingRecordsTable, LendingRow>,
      ),
      LendingRow,
      PrefetchHooks Function()
    >;
typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String name,
  required List<TimeOfDayMinutes> times,
  Value<Set<int>> weekdays,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> name,
  Value<List<TimeOfDayMinutes>> times,
  Value<Set<int>> weekdays,
  Value<bool> enabled,
  Value<int> rowid,
});

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<TimeOfDayMinutes>,
    List<TimeOfDayMinutes>,
    String
  >
  get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<int>, Set<int>, String> get weekdays =>
      $composableBuilder(
        column: $table.weekdays,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<TimeOfDayMinutes>, String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<int>, String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$MedicinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTable,
          MedicineRow,
          $$MedicinesTableFilterComposer,
          $$MedicinesTableOrderingComposer,
          $$MedicinesTableAnnotationComposer,
          $$MedicinesTableCreateCompanionBuilder,
          $$MedicinesTableUpdateCompanionBuilder,
          (
            MedicineRow,
            BaseReferences<_$AppDatabase, $MedicinesTable, MedicineRow>,
          ),
          MedicineRow,
          PrefetchHooks Function()
        > {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<TimeOfDayMinutes>> times = const Value.absent(),
                Value<Set<int>> weekdays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                times: times,
                weekdays: weekdays,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String name,
                required List<TimeOfDayMinutes> times,
                Value<Set<int>> weekdays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                times: times,
                weekdays: weekdays,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicinesTable, MedicineRow>(table),
                  BaseReferences<_$AppDatabase, $MedicinesTable, MedicineRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTable,
      MedicineRow,
      $$MedicinesTableFilterComposer,
      $$MedicinesTableOrderingComposer,
      $$MedicinesTableAnnotationComposer,
      $$MedicinesTableCreateCompanionBuilder,
      $$MedicinesTableUpdateCompanionBuilder,
      (
        MedicineRow,
        BaseReferences<_$AppDatabase, $MedicinesTable, MedicineRow>,
      ),
      MedicineRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShoppingListsTableTableManager get shoppingLists =>
      $$ShoppingListsTableTableManager(_db, _db.shoppingLists);
  $$ShoppingItemsTableTableManager get shoppingItems =>
      $$ShoppingItemsTableTableManager(_db, _db.shoppingItems);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $DocumentsFtsTableManager get documentsFts =>
      $DocumentsFtsTableManager(_db, _db.documentsFts);
  $$PasswordNotesTableTableManager get passwordNotes =>
      $$PasswordNotesTableTableManager(_db, _db.passwordNotes);
  $PasswordNotesFtsTableManager get passwordNotesFts =>
      $PasswordNotesFtsTableManager(_db, _db.passwordNotesFts);
  $$PersonalEntriesTableTableManager get personalEntries =>
      $$PersonalEntriesTableTableManager(_db, _db.personalEntries);
  $PersonalEntriesFtsTableManager get personalEntriesFts =>
      $PersonalEntriesFtsTableManager(_db, _db.personalEntriesFts);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $NotesFtsTableManager get notesFts =>
      $NotesFtsTableManager(_db, _db.notesFts);
  $$NoteAttachmentsTableTableManager get noteAttachments =>
      $$NoteAttachmentsTableTableManager(_db, _db.noteAttachments);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskChecklistItemsTableTableManager get taskChecklistItems =>
      $$TaskChecklistItemsTableTableManager(_db, _db.taskChecklistItems);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$BudgetAmountsTableTableManager get budgetAmounts =>
      $$BudgetAmountsTableTableManager(_db, _db.budgetAmounts);
  $$LendingRecordsTableTableManager get lendingRecords =>
      $$LendingRecordsTableTableManager(_db, _db.lendingRecords);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
}
