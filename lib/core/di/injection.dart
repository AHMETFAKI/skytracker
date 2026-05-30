import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../config/data_source.dart';
import 'injection.config.dart';

/// Global service locator.
final GetIt getIt = GetIt.instance;

/// Wires up every `@injectable` registration. The [dataSource] selects between
/// the `mock` and `remote` flight repository implementations via injectable
/// `@Environment` filtering.
@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies(DataSource dataSource) async {
  await getIt.init(environment: dataSource.envName);
}
