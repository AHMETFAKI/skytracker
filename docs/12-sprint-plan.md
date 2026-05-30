# 12 — Sprint / Faz Planı

10 günlük süreye yayılan faz bazlı plan. Her faz **bağımsız commit + push** ile kapanır.
Durum işaretleri ilerledikçe [00-roadmap.md](00-roadmap.md) ile senkron tutulur.

## Faz 0 — Repo & docs (🟡)
- [x] Temiz `git init` (skytracker), genişletilmiş `.gitignore`
- [x] `docs/*.md` taslakları
- [ ] `.env.example`, kök README iskeleti
- [ ] `gh repo create skytracker --public` + ilk commit/push
- Commit: `chore: project docs & repo setup`

## Faz 1 — Bağımlılıklar & yapı
- [ ] `pubspec.yaml` tüm zorunlu + destek paketleri
- [ ] `analysis_options.yaml` sıkılaştırma
- [ ] Klasör iskeleti (core/ + features/)
- [ ] Android `minSdk=23`, izinler (INTERNET, konum), `applicationId`
- [ ] `main.dart` + `bootstrap.dart`, ScreenUtil + EasyLocalization init, `tr/en.json` iskelet
- [ ] İlk `build_runner` koşusu temiz
- Commit: `chore: dependencies & project skeleton`

## Faz 2 — Core
- [ ] `Failure` (freezed), Exception'lar, `failure_mapper`
- [ ] `dio_client` + Auth/Retry interceptor + `network_info`
- [ ] `injectable` DI (`configureDependencies(environment)`) + `register_module`
- [ ] `auto_route` router + `AuthGuard`
- [ ] Radar teması (colors/theme/text styles)
- [ ] `unit_converters`, `validators`
- [ ] Ortak widget'lar (AppButton/AppTextField/AppScaffold/Loading/Error/Empty/GlassCard)
- Commit: `feat: core layer (error, network, di, router, theme)`

## Faz 3 — Flights domain + data
- [ ] `FlightEntity`, `IFlightRepository`
- [ ] `FlightStateDto` (pozisyonel fromJson) + `toEntity`
- [ ] `FlightMockDataSource` + `assets/mock/flights_mock.json`
- [ ] `FlightRemoteDataSource` (OpenSky OAuth2) + token cache
- [ ] `@Environment('mock'/'remote')` repo'lar + DATA_SOURCE switch
- [ ] Birim testleri (DTO map, converters)
- Commit: `feat: flights data layer + mock/remote switching`

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
