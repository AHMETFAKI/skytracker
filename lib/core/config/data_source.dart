/// Selects which [IFlightRepository] implementation the DI container wires up.
/// Driven by `--dart-define=DATA_SOURCE=mock|remote` (default mock) and mapped
/// to injectable `@Environment` names.
enum DataSource {
  mock('mock'),
  remote('remote');

  const DataSource(this.envName);

  /// Matches the injectable `@Environment(...)` string for this source.
  final String envName;

  /// Parses the `DATA_SOURCE` dart-define. Falls back to [DataSource.mock]
  /// for any unknown / empty value so the app always runs keyless.
  static DataSource fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'remote' => DataSource.remote,
      _ => DataSource.mock,
    };
  }

  /// Resolves the active source with a clear precedence:
  /// `--dart-define` wins, then the `.env` value, otherwise [DataSource.mock].
  /// [define] is the `String.fromEnvironment('DATA_SOURCE')` value (empty when
  /// the dart-define is absent); [envValue] is `dotenv.maybeGet('DATA_SOURCE')`.
  static DataSource resolve({required String define, String? envValue}) {
    final raw = define.trim().isNotEmpty ? define : envValue;
    return fromString(raw);
  }
}
