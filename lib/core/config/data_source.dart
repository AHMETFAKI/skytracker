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
}
