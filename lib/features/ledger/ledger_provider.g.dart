// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ledgerListHash() => r'c5869c40551267df79fdc83af61c5bfeb62937da';

/// See also [ledgerList].
@ProviderFor(ledgerList)
final ledgerListProvider =
    AutoDisposeFutureProvider<List<TransactionWithImages>>.internal(
  ledgerList,
  name: r'ledgerListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ledgerListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LedgerListRef
    = AutoDisposeFutureProviderRef<List<TransactionWithImages>>;
String _$ledgerSummaryHash() => r'0ec07d8d12d40fcea2339182d7b668c01ebd6d76';

/// See also [ledgerSummary].
@ProviderFor(ledgerSummary)
final ledgerSummaryProvider = AutoDisposeFutureProvider<LedgerSummary>.internal(
  ledgerSummary,
  name: r'ledgerSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ledgerSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LedgerSummaryRef = AutoDisposeFutureProviderRef<LedgerSummary>;
String _$categoryStatisticsHash() =>
    r'558058bd8d0340fd0e1fd18b230b147719858e9f';

/// See also [categoryStatistics].
@ProviderFor(categoryStatistics)
final categoryStatisticsProvider = AutoDisposeFutureProvider<
    List<({String category, int amount, double percentage})>>.internal(
  categoryStatistics,
  name: r'categoryStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryStatisticsRef = AutoDisposeFutureProviderRef<
    List<({String category, int amount, double percentage})>>;
String _$annualCategoryStatisticsHash() =>
    r'0318d67828fb7e44f7bfcdce656b55bdd2bddf76';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [annualCategoryStatistics].
@ProviderFor(annualCategoryStatistics)
const annualCategoryStatisticsProvider = AnnualCategoryStatisticsFamily();

/// See also [annualCategoryStatistics].
class AnnualCategoryStatisticsFamily extends Family<
    AsyncValue<List<({String category, int amount, double percentage})>>> {
  /// See also [annualCategoryStatistics].
  const AnnualCategoryStatisticsFamily();

  /// See also [annualCategoryStatistics].
  AnnualCategoryStatisticsProvider call(
    int year,
  ) {
    return AnnualCategoryStatisticsProvider(
      year,
    );
  }

  @override
  AnnualCategoryStatisticsProvider getProviderOverride(
    covariant AnnualCategoryStatisticsProvider provider,
  ) {
    return call(
      provider.year,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'annualCategoryStatisticsProvider';
}

/// See also [annualCategoryStatistics].
class AnnualCategoryStatisticsProvider extends AutoDisposeFutureProvider<
    List<({String category, int amount, double percentage})>> {
  /// See also [annualCategoryStatistics].
  AnnualCategoryStatisticsProvider(
    int year,
  ) : this._internal(
          (ref) => annualCategoryStatistics(
            ref as AnnualCategoryStatisticsRef,
            year,
          ),
          from: annualCategoryStatisticsProvider,
          name: r'annualCategoryStatisticsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$annualCategoryStatisticsHash,
          dependencies: AnnualCategoryStatisticsFamily._dependencies,
          allTransitiveDependencies:
              AnnualCategoryStatisticsFamily._allTransitiveDependencies,
          year: year,
        );

  AnnualCategoryStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
  }) : super.internal();

  final int year;

  @override
  Override overrideWith(
    FutureOr<List<({String category, int amount, double percentage})>> Function(
            AnnualCategoryStatisticsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnnualCategoryStatisticsProvider._internal(
        (ref) => create(ref as AnnualCategoryStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<
          List<({String category, int amount, double percentage})>>
      createElement() {
    return _AnnualCategoryStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnualCategoryStatisticsProvider && other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AnnualCategoryStatisticsRef on AutoDisposeFutureProviderRef<
    List<({String category, int amount, double percentage})>> {
  /// The parameter `year` of this provider.
  int get year;
}

class _AnnualCategoryStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<
        List<({String category, int amount, double percentage})>>
    with AnnualCategoryStatisticsRef {
  _AnnualCategoryStatisticsProviderElement(super.provider);

  @override
  int get year => (origin as AnnualCategoryStatisticsProvider).year;
}

String _$searchTransactionsHash() =>
    r'949a76ee2ab955d68a8c5af063d4cf2cc4274e1b';

/// See also [searchTransactions].
@ProviderFor(searchTransactions)
const searchTransactionsProvider = SearchTransactionsFamily();

/// See also [searchTransactions].
class SearchTransactionsFamily extends Family<AsyncValue<List<Transaction>>> {
  /// See also [searchTransactions].
  const SearchTransactionsFamily();

  /// See also [searchTransactions].
  SearchTransactionsProvider call(
    String keyword,
  ) {
    return SearchTransactionsProvider(
      keyword,
    );
  }

  @override
  SearchTransactionsProvider getProviderOverride(
    covariant SearchTransactionsProvider provider,
  ) {
    return call(
      provider.keyword,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchTransactionsProvider';
}

/// See also [searchTransactions].
class SearchTransactionsProvider
    extends AutoDisposeFutureProvider<List<Transaction>> {
  /// See also [searchTransactions].
  SearchTransactionsProvider(
    String keyword,
  ) : this._internal(
          (ref) => searchTransactions(
            ref as SearchTransactionsRef,
            keyword,
          ),
          from: searchTransactionsProvider,
          name: r'searchTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchTransactionsHash,
          dependencies: SearchTransactionsFamily._dependencies,
          allTransitiveDependencies:
              SearchTransactionsFamily._allTransitiveDependencies,
          keyword: keyword,
        );

  SearchTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.keyword,
  }) : super.internal();

  final String keyword;

  @override
  Override overrideWith(
    FutureOr<List<Transaction>> Function(SearchTransactionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchTransactionsProvider._internal(
        (ref) => create(ref as SearchTransactionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        keyword: keyword,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Transaction>> createElement() {
    return _SearchTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTransactionsProvider && other.keyword == keyword;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, keyword.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SearchTransactionsRef on AutoDisposeFutureProviderRef<List<Transaction>> {
  /// The parameter `keyword` of this provider.
  String get keyword;
}

class _SearchTransactionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Transaction>>
    with SearchTransactionsRef {
  _SearchTransactionsProviderElement(super.provider);

  @override
  String get keyword => (origin as SearchTransactionsProvider).keyword;
}

String _$calendarEventsHash() => r'ad4f28daa7447e24bea469175936557289b01292';

/// See also [calendarEvents].
@ProviderFor(calendarEvents)
final calendarEventsProvider =
    AutoDisposeFutureProvider<Map<DateTime, List<Transaction>>>.internal(
  calendarEvents,
  name: r'calendarEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarEventsRef
    = AutoDisposeFutureProviderRef<Map<DateTime, List<Transaction>>>;
String _$monthlyTrendHash() => r'b0ab52bb28c76743103e7abae5aed883ad6c5361';

/// See also [monthlyTrend].
@ProviderFor(monthlyTrend)
final monthlyTrendProvider = AutoDisposeFutureProvider<
    List<({DateTime month, int income, int expense})>>.internal(
  monthlyTrend,
  name: r'monthlyTrendProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$monthlyTrendHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyTrendRef = AutoDisposeFutureProviderRef<
    List<({DateTime month, int income, int expense})>>;
String _$selectedDateHash() => r'01c4672ca9cceba0a1486248e4a808727b6c3437';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$ledgerActionHash() => r'e78d40d1da0da3e5ab301cdad3897ecbd458dee1';

/// See also [LedgerAction].
@ProviderFor(LedgerAction)
final ledgerActionProvider =
    AutoDisposeAsyncNotifierProvider<LedgerAction, void>.internal(
  LedgerAction.new,
  name: r'ledgerActionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ledgerActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LedgerAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
