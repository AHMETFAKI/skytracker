# 02 — Mimari (Clean Architecture)

## İlke
Üç katman: **Presentation → Domain → Data**. Bağımlılık oku **içe** doğrudur: Presentation ve
Data, Domain'e bağımlıdır; Domain hiçbir dış katmana bağımlı **değildir** ve saf Dart'tır
(Flutter/Firebase/dio importu yoktur).

```
┌──────────────── Presentation ────────────────┐
│  Pages (HookConsumerWidget) · Riverpod        │
│  Providers · Freezed State · Widgets          │
└───────────────────┬───────────────────────────┘
                    │ depends on
┌───────────────────▼──────── Domain ───────────┐
│  Entities (saf Dart) · Repository interface'leri│
│  UseCase'ler (opsiyonel) · Failure             │
└───────────────────▲──────────────────────────┘
                    │ implements
┌───────────────────┴──────── Data ─────────────┐
│  DataSource (remote/mock) · DTO (freezed+json) │
│  Repository implementasyonları (Either map)    │
└────────────────────────────────────────────────┘
```

## Veri akışı
1. **UI** bir Riverpod provider'ı izler/çağırır.
2. **Provider** repository (veya use case) çağırır → `Future<Either<Failure, T>>`.
3. **Repository impl** DataSource'u çağırır, exception → `Failure`'a map eder, DTO → Entity dönüşür.
4. **Provider** `Either`'ı katlar (`fold`) → state (loading/data/failure).
5. **UI** state'e göre render eder (loading/empty/error/data).

## Hata yönetimi — `Either<Failure, T>` (fpdart)
- Tüm repository/usecase imzaları `Future<Either<Failure, T>>` döner. İstisna fırlatmak yerine
  hata, tip düzeyinde taşınır → çağıran tarafı hatayı **ele almaya zorlanır**.
- DataSource katmanı tipli **Exception** fırlatır; Repository bunları **Failure**'a çevirir.

### Failure hiyerarşisi (freezed sealed)
| Failure | Kaynak | Kullanıcıya mesaj (i18n key) |
|---|---|---|
| `ServerFailure` | 5xx / beklenmeyen API | `error.server` |
| `NetworkFailure` | bağlantı yok / timeout | `error.network` |
| `AuthFailure` | 401 Unauthorized | `error.auth` |
| `RateLimitFailure` | 429 Too Many Requests | `error.rateLimit` |
| `CacheFailure` | yerel okuma/yazma | `error.cache` |
| `LocationFailure` | konum izni/servis | `error.location` |
| `UnknownFailure` | sınıflandırılamayan | `error.unknown` |

`Failure` → kullanıcı mesajı eşlemesi tek yerde (`failure_message_mapper` + i18n) yapılır.

## Katman sorumlulukları
- **Domain:** `FlightEntity`, `UserEntity`, `IFlightRepository`, `IAuthRepository`,
  `IProfileRepository`, `Failure`. Hiçbir framework importu yok.
- **Data:** `FlightStateDto` (json_serializable), `FlightRemoteDataSource` (dio),
  `FlightMockDataSource` (asset JSON), `*RepositoryImpl` (Either + DTO→Entity).
- **Presentation:** sayfalar, `@riverpod`/Notifier provider'lar, freezed `*State` sınıfları,
  feature widget'ları.

## Test edilebilirlik
- Domain saf olduğundan use case/entity testleri framework gerektirmez.
- Repository, DataSource interface'leri üzerinden mock'lanabilir.
- `DATA_SOURCE=mock` ile uçtan uca akış dış bağımlılık olmadan çalışır.
