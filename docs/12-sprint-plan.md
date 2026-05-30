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

## Faz 4 — Harita
- [ ] `MapLibreMap` + MapTiler koyu stil (graceful degrade)
- [ ] GeoJSON source + Symbol Layer + `iconRotate=true_track`
- [ ] `flightsProvider` periyodik yenileme + fallback UX
- [ ] Flight Info Bottom Sheet (ft + km/h + durum)
- [ ] Konum FAB (geolocator + permission_handler)
- Commit: `feat: flight map screen`

## Faz 5 — Auth & Firestore
- [ ] `IAuthRepository` + Firebase impl (register/login/logout)
- [ ] Firestore `users/{uid}` yaz/oku
- [ ] Login/Register sayfaları + validasyon + "Beni Hatırlat"
- [ ] `firestore.rules`
- Commit: `feat: auth & firestore profile`

## Faz 6 — Shell & Profil
- [ ] `AutoTabsScaffold` 2 sekme (Harita/Profil)
- [ ] Profil: oku / Ad Soyad düzenle / çıkış
- [ ] `AuthGuard` redirect
- Commit: `feat: shell navigation & profile screen`

## Faz 7 — Lokalizasyon & cila
- [ ] TR/EN tüm anahtarlar
- [ ] Responsive geçiş kontrolü
- [ ] loading/empty/error tutarlılığı
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
