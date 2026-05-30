# 05 — Data Switching (Mock / Remote + Fallback)

Spec'in en ayırt edici beklentisi: uygulamanın **dış bağımlılıktan bağımsız** test/demo
edilebilmesi ve API hatalarına **tolerans** göstermesi.

## Repository sözleşmesi (domain)
```dart
abstract interface class IFlightRepository {
  Future<Either<Failure, List<FlightEntity>>> getStates({BoundingBox? bbox});
}
```
İki implementasyon:
- `FlightRemoteRepository` → `FlightRemoteDataSource` (dio + OpenSky).
- `FlightMockRepository` → `FlightMockDataSource` (`assets/mock/flights_mock.json`).

Mock JSON, OpenSky `/states/all` cevabıyla **birebir** aynı şemadadır (aynı DTO parse eder) →
mock'tan remote'a geçişte presentation hiç değişmez.

## Switch mekanizması — injectable `@Environment`
```dart
@Environment('remote')
@LazySingleton(as: IFlightRepository)
class FlightRemoteRepository implements IFlightRepository { ... }

@Environment('mock')
@LazySingleton(as: IFlightRepository)
class FlightMockRepository implements IFlightRepository { ... }
```
`bootstrap.dart` ortam değişkenini okur ve DI'yı o ortamla başlatır:
```dart
const raw = String.fromEnvironment('DATA_SOURCE', defaultValue: 'mock');
final env = raw == 'remote' ? 'remote' : 'mock';
await configureDependencies(environment: env);
```
> **Tek komutla geçiş:**
> - Mock: `flutter run --dart-define=DATA_SOURCE=mock` (varsayılan)
> - Gerçek: `flutter run --dart-define=DATA_SOURCE=remote`

`.env` içindeki `DATA_SOURCE` de okunabilir; `--dart-define` önceliklidir (CI/flavor dostu).

## Fallback (hata toleransı — artı puan)
Remote repo `AuthFailure` (401) veya `RateLimitFailure` (429) döndürdüğünde:
1. **Bilgilendirme:** Harita ekranı kullanıcıya açıklayıcı bir SnackBar/Banner gösterir.
2. **Manuel geçiş:** SnackBar'da **"Mock veriye geç"** aksiyonu — provider runtime'da
   `getIt<FlightMockRepository>()`'a döner (named/registered instance).
3. **Otomatik geçiş (opsiyonel):** `AppConfig.autoFallbackToMock == true` ise 401/429'da
   provider sessizce mock'a düşer ve bir bilgi etiketi gösterir ("Mock veri").

Bu davranış presentation katmanındaki `flightsProvider` içinde, repository çağrısının
`fold`'unda merkezî olarak ele alınır.

## Doğrulama
- `DATA_SOURCE=mock` → harita mock uçaklarla dolu (anahtarsız çalışır).
- `DATA_SOURCE=remote` geçersiz token → 401 → fallback akışı tetiklenir.
- Aynı DTO her iki kaynakta parse ediliyor (regresyon yok).
