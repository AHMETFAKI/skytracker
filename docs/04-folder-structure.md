# 04 — Klasör Yapısı

```
lib/
├── main.dart                       # Entrypoint: DATA_SOURCE okur → bootstrap()
├── bootstrap.dart                  # .env yükle, Firebase init, DI init, runApp(ProviderScope)
│
├── core/
│   ├── config/
│   │   ├── app_config.dart         # Sabitler, default'lar (refresh interval, autoFallback)
│   │   └── data_source.dart        # enum DataSource { mock, remote }
│   ├── di/
│   │   ├── injection.dart          # @InjectableInit getIt + configureDependencies(env)
│   │   └── register_module.dart    # 3p nesneler (Dio, FirebaseAuth, Firestore, prefs)
│   ├── error/
│   │   ├── failure.dart            # freezed sealed Failure
│   │   ├── exceptions.dart         # ServerException, AuthException, RateLimitException ...
│   │   └── failure_mapper.dart     # Exception/DioException → Failure, Failure → i18n key
│   ├── network/
│   │   ├── dio_client.dart         # Dio factory (baseUrl, timeouts)
│   │   ├── auth_interceptor.dart   # OAuth2 Bearer ekleme + 401 refresh
│   │   ├── retry_interceptor.dart  # 429 backoff
│   │   └── network_info.dart       # bağlantı kontrolü
│   ├── router/
│   │   ├── app_router.dart         # @AutoRouterConfig route ağacı
│   │   └── guards/auth_guard.dart  # oturum yoksa Login'e
│   ├── theme/
│   │   ├── app_colors.dart         # radar/kokpit paleti
│   │   ├── app_theme.dart          # ThemeData (dark)
│   │   └── app_text_styles.dart
│   ├── localization/
│   │   └── locale_keys.dart        # (opsiyonel) üretilen anahtarlar
│   ├── utils/
│   │   ├── unit_converters.dart    # metersToFeet, mpsToKmh
│   │   └── validators.dart         # email/şifre/boş alan
│   └── widgets/                    # ORTAK widget kütüphanesi (hardcoded renk YOK)
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_scaffold.dart
│       ├── loading_overlay.dart
│       ├── app_error_view.dart
│       └── empty_view.dart
│
└── features/
    ├── auth/
    │   ├── data/{datasources,dtos,repositories}
    │   ├── domain/{entities,repositories}
    │   └── presentation/{pages,providers,state,widgets}
    ├── flights/
    │   ├── data/
    │   │   ├── datasources/flight_remote_data_source.dart
    │   │   ├── datasources/flight_mock_data_source.dart
    │   │   ├── dtos/flight_state_dto.dart
    │   │   └── repositories/flight_remote_repository.dart
    │   │   └── repositories/flight_mock_repository.dart
    │   ├── domain/
    │   │   ├── entities/flight_entity.dart
    │   │   └── repositories/i_flight_repository.dart
    │   └── presentation/
    │       ├── pages/flight_map_page.dart
    │       ├── providers/flights_provider.dart
    │       ├── state/flights_state.dart
    │       └── widgets/flight_info_sheet.dart
    ├── profile/
    │   ├── data/ · domain/ · presentation/
    └── shell/
        └── presentation/shell_page.dart   # AutoTabsScaffold (2 sekme)

assets/
├── mock/flights_mock.json
├── images/plane.png                # marker ikonu
└── translations/{en.json, tr.json}

test/                               # birim testleri (converters, validators, dto, mapper)
.github/workflows/ci.yml            # CI
firestore.rules                     # Security Rules
.env.example                        # secret şablonu
```

## Kurallar
- **Domain** klasörlerinde Flutter/Firebase/dio importu yasak.
- Feature dışına sızması gereken ortak şeyler `core/`'a taşınır.
- UI'da renk/spacing literal'i yok → `core/theme` + `core/widgets`.
