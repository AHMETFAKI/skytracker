# 12 — Sprint / Faz Planı

10 günlük süreye yayılan faz bazlı plan. Her faz **bağımsız commit + push** ile kapanır.
Durum işaretleri ilerledikçe [00-roadmap.md](00-roadmap.md) ile senkron tutulur.

## Faz 0 — Repo & docs (🟡)
- [x] Temiz `git init` (skytracker), genişletilmiş `.gitignore`
- [x] `docs/*.md` taslakları
- [ ] `.env.example`, kök README iskeleti
- [ ] `gh repo create skytracker --public` + ilk commit/push
- Commit: `chore: project docs & repo setup`

## Faz 1 — Bağımlılıklar & yapı ✅
- [x] `pubspec.yaml` tüm zorunlu + destek paketleri
- [x] `analysis_options.yaml` sıkılaştırma (+ generated exclude)
- [x] Mobil-odak: desktop/web platform iskeletleri kaldırıldı (android + ios)
- [x] Android `minSdk=23`, izinler (INTERNET, ACCESS_NETWORK_STATE, konum)
- [x] `main.dart` + `bootstrap.dart` + `app.dart`, ScreenUtil + EasyLocalization init
- [x] `assets/` (mock json, translations tr/en, images placeholder) + `.env`
- [x] `flutter analyze` 0 issue, `flutter test` yeşil
- Commit: `chore: dependencies & project skeleton`
- Not: klasör iskeleti (core/ + features/) gerçek dosyalarla Faz 2'de oluşturulacak.

## Faz 2 — Core ✅
- [x] `Failure` (freezed sealed) + Exception'lar + `failure_mapper` (Dio/AppException → Failure)
- [x] `dio_client` (module) + `RetryInterceptor` (429 backoff) + `LogInterceptor` + `network_info`
- [x] `injectable` DI (`configureDependencies(DataSource)`) + `register_module` (prefs, secure storage)
- [x] `auto_route` router + placeholder `SplashRoute`
- [x] Radar teması (colors/theme/text styles → `AppTheme.dark`)
- [x] `unit_converters` (m→ft, m/s→km/h), `validators` (i18n key dönüşlü)
- [x] Ortak widget'lar (AppButton/AppTextField/GlassCard/LoadingView/AppErrorView/EmptyView/MockDataBanner)
- [x] `flutter analyze` 0 issue, `flutter test` yeşil, build_runner üretildi
- Commit: `feat: core layer (error, network, di, router, theme)`
- Not: `AuthInterceptor` (OpenSky token) → Faz 3'e, `AuthGuard` (auth state) → Faz 5/6'ya ertelendi.
  `AppScaffold` ihtiyaç anında (Faz 4 shell) eklenecek; temel iskelet `Scaffold` + tema ile karşılanıyor.

## Faz 3 — Flights domain + data ✅
- [x] `FlightEntity` (freezed) + `BoundingBox` + `IFlightRepository`
- [x] `FlightStateDto` (pozisyonel `fromStateVector`) + `toEntity` (konumsuz uçak elenir)
- [x] `FlightMockDataSource` + mevcut `assets/mock/flights_mock.json` (OpenSky şeması)
- [x] `OpenSkyAuthService` (OAuth2 client-credentials, secure storage token cache) + `AuthInterceptor` (401→tek yenileme)
- [x] `FlightRemoteDataSource` (named `opensky` Dio: retry+auth+log) + `FlightRemoteRepository`
- [x] `@Environment('mock'/'remote')` binding modülü; mock repo her ortamda concrete (fallback'a hazır)
- [x] Birim testleri (DTO map + toEntity, unit converters) — 12 test yeşil
- Commit: `feat: flights data layer + mock/remote switching`
- Not: `AccessTokenProvider` core'da interface; OpenSky impl feature'da (Clean Arch bağımlılık yönü korunur).

## Faz 4 — Harita ✅
- [x] `MapLibreMap` + MapTiler koyu stil; anahtar yoksa demo stile graceful degrade (`AppConfig.mapStyleUrl`)
- [x] GeoJSON source (`promoteId=icao24`) + Symbol Layer + `iconRotate=['get','bearing']`; ikon runtime'da çizilir (asset yok)
- [x] `flightsControllerProvider` (AsyncNotifier) periyodik yenileme + otomatik/manuel mock fallback
- [x] Flight Info Bottom Sheet (çağrı kodu, menşe, irtifa ft, hız km/h, yerde/havada)
- [x] Konum FAB (permission_handler izin + geolocator konum → animateCamera)
- [x] `flutter analyze` 0 issue, `flutter test` yeşil (12 test)
- Commit: `feat: flight map screen`
- Not: Harita native plugin gerektirir; canlı görsel doğrulama (marker dönüşü, tap, konum) kullanıcı
  cihazı/emülatöründe yapılmalı. APK derlemesi bu ortamda Gradle loopback kısıtı nedeniyle koşulamadı;
  Faz 8 CI runner'ında doğrulanacak.

## Faz 5 — Auth & Firestore ✅
- [x] `IAuthRepository` + `FirebaseAuthRepository` (register/login/logout, `users/{uid}` oku/yaz, `fullName` update)
- [x] `AppUser` entity (freezed) + `AuthFailureMapper` (Firebase kodları → lokalize `Failure`)
- [x] Login/Register sayfaları (hooks, validator'lı) + "Beni Hatırlat" (`RememberMeStore` + cold-start oturum temizliği)
- [x] Tolerant Firebase init (config yoksa app çökmeden mock-first çalışır) + koşullu `google-services` Gradle eklentisi
- [x] `firestore.rules` (kullanıcı yalnızca kendi dokümanı; `update` yalnızca `fullName`; default-deny)
- [x] `flutter analyze` 0 issue, `flutter test` yeşil (17 test: +5 AuthFailureMapper)
- Commit: `feat: auth & firestore profile`
- Not: `firebase_options.dart` / `google-services.json` gitignore — kullanıcı `flutterfire configure` ile üretir.
  Canlı auth doğrulaması (kayıt/giriş → Firestore dokümanı) gerçek Firebase projesi gerektirir; rules
  Rules Simulator/CI ile doğrulanacak. `AuthGuard` redirect → Faz 6 (shell ile birlikte).

## Faz 6 — Shell & Profil ✅
- [x] `HomeShellPage` (`AutoTabsScaffold`) 2 sekme (Harita/Profil) + radar temalı `BottomNavigationBar`
- [x] `ProfilePage` + `ProfileController` (Firestore `users/{uid}` oku, `fullName` düzenle bottom sheet, çıkış)
- [x] `AuthGuard` → kimlik yoksa `LoginRoute`'a yönlendirir; Firebase yapılandırılmamışsa no-op (mock-first geçişi açık)
- [x] Giriş/kayıt başarısında `HomeShellRoute`'a `replaceAll`; oturum kapalıyken profil sekmesi "giriş yap" CTA'sı
- [x] `flutter analyze` 0 issue, `flutter test` yeşil (17 test)
- Commit: `feat: shell navigation & profile screen`
- Not: Sekme geçişi + profil düzenleme canlı doğrulaması gerçek Firebase oturumu gerektirir; guard mantığı
  hem yapılandırılmış (auth zorunlu) hem mock-first (auth bypass) senaryosunu kapsar.

## Faz 7 — Lokalizasyon & cila ✅
- [x] TR/EN tüm anahtarlar tam; `translations_parity_test` ile anahtar kümeleri eşitlik garantisi
- [x] `LanguageToggle` (runtime TR/EN geçişi) — login ve profil ekranlarında
- [x] Hata gösterimi tek noktadan: `failureMessage`/`showFailureSnackBar`; harita error overlay'i de bu yardımcıyı kullanır
- [x] loading/empty/error tutarlılığı: `LoadingView`/`EmptyView`/`AppErrorView` ortak widget'larıyla
- [x] Tüm kullanıcı metinleri `.tr()` (hardcoded string yok); ScreenUtil ile responsive ölçekleme
- [x] `flutter analyze` 0 issue, `flutter test` yeşil (18 test: +1 çeviri parity)
- Commit: `feat: localization & ui polish`

## Faz 8 — CI/CD & test
- [ ] `.github/workflows/ci.yml`
- [ ] Birim testleri (validators, failure_mapper, dto)
- Commit: `ci: github actions + unit tests`

## Faz 9 — Teslim
- [ ] Kök `README.md` + `FIREBASE_README.md` final
- [ ] `flutter build apk --release` → APK
- [ ] Demo videosu (kullanıcı)
- [ ] Repo public + link
- Commit: `docs: delivery readme + apk`
