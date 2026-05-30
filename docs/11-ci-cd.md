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

> Firebase: CI'da gerçek `google-services.json` yoktur. Build'in firebase olmadan da
> derlenebilmesi için Android tarafında placeholder strateji izlenir veya APK build adımı
> `DATA_SOURCE=mock` ve dummy `google-services.json` (CI secret) ile yapılır. Tercih:
> CI'da APK adımı yalnızca **analyze+test** sonrası, eksik secret'ta `continue-on-error` yerine
> minimal dummy ile derlenir (karar Faz 8'de netleşir, burada güncellenir).

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
