# 11 — CI/CD (GitHub Actions)

## Amaç
Her push/PR'da kalite kapısı: kod üretimi → statik analiz → testler → APK build. Generated
dosyalar repoda tutulmadığı için CI **build_runner'ı çalıştırır**.

## `.github/workflows/ci.yml`
Adımlar:
1. `actions/checkout`
2. `subosito/flutter-action` ile Flutter **stable** kurulumu (cache açık).
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `flutter analyze` (uyarı/hatada kırmızı)
6. `flutter test`
7. `flutter build apk --debug` (derlenebilirlik kanıtı)

> **Firebase (çözüldü):** CI'da gerçek `google-services.json` yoktur ve **dummy dosya da
> gerekmez**. `android/app/build.gradle.kts` içinde `google-services` Gradle eklentisi yalnızca
> dosya mevcutsa uygulanır (`if (file("google-services.json").exists())`). Böylece debug APK,
> mock-first konfigürasyonda sorunsuz derlenir; `firebase_init.dart` tolerant init ile config
> yokken uygulama çökmeden çalışır. CI bu sayede ekstra secret olmadan derleme kanıtı üretir.

## Birim testleri (Faz 8)
`flutter test` adımının kapsadığı saf birim testleri (toplam 39 test):
- `validators_test.dart` — e-posta/şifre/şifre tekrar/ad doğrulayıcıları (i18n key dönüşleri).
- `failure_mapper_test.dart` — `AppException` ve `DioException` (401/429/500, timeout, unknown) → `Failure`.
- `auth_failure_mapper_test.dart` — Firebase auth kodları → lokalize `Failure`.
- `flight_state_dto_test.dart` — OpenSky state vector → DTO/Entity map'leme.
- `unit_converters_test.dart` — m→ft, m/s→km/h/knots dönüşümleri ve formatlama.
- `translations_parity_test.dart` — TR/EN anahtar kümesi eşitliği.

## Tetikleyiciler
- `push` → `main`
- `pull_request` → `main`

## Release (opsiyonel) — `.github/workflows/release.yml`
- `tags: v*` → release APK build → `actions/upload-artifact` / GitHub Release'e APK ekleme.
- Teslim APK'sı bu yolla repoya Release olarak iliştirilebilir.

## Lokal eşdeğer komutlar
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release   # teslim APK
```
