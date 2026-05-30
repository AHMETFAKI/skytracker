# SkyTracker ✈️

Gerçek zamanlı uçuş verilerini ([OpenSky Network](https://opensky-network.org)) bir MapLibre
haritası üzerinde takip eden Flutter uygulaması. PITON Technology Study Case projesi.

> **Durum:** Geliştirme aşamasında — yol haritası için [`docs/00-roadmap.md`](docs/00-roadmap.md).

## Özellikler
- 🗺️ MapLibre GL haritada uçaklar (GeoJSON Symbol Layer, `true_track` ile dönen ikonlar)
- ℹ️ Uçağa tıkla → bilgi kartı (callsign, ülke, irtifa **ft**, hız **km/h**, yerde/havada)
- 📍 Cihaz konumuna ortalayan buton
- 🔁 **Mock / Remote** veri kaynağı tek komutla değişir + 401/429'da mock'a fallback
- 🔐 Firebase Auth (e-posta/şifre) + "Beni Hatırlat" + Firestore profil
- 🌍 TR / EN lokalizasyon
- 🧱 Clean Architecture + `Either<Failure,T>` ile merkezî hata yönetimi

## Teknoloji yığını
Flutter · hooks_riverpod + flutter_hooks · get_it + injectable · auto_route · dio · maplibre_gl ·
Firebase (Auth + Firestore) · freezed + json_serializable · fpdart · easy_localization ·
flutter_screenutil. Gerekçeler: [`docs/03-tech-stack.md`](docs/03-tech-stack.md).

## Kurulum
```bash
# 1) Bağımlılıklar
flutter pub get

# 2) Kod üretimi (freezed / json / injectable / auto_route)
dart run build_runner build --delete-conflicting-outputs

# 3) Ortam dosyası
cp .env.example .env   # OpenSky & MapTiler anahtarlarını doldur (mock mod için gerekmez)

# 4) Firebase (gerçek auth için)
flutterfire configure  # lib/firebase_options.dart üretir (gitignore)
```

## Çalıştırma
```bash
# Mock veri (anahtarsız, varsayılan)
flutter run --dart-define=DATA_SOURCE=mock

# Gerçek OpenSky verisi (.env anahtarları gerekir)
flutter run --dart-define=DATA_SOURCE=remote
```
Tek satırlık `DATA_SOURCE` bayrağı tüm uygulamayı mock/remote arasında çevirir
(bkz. [`docs/05-data-switching.md`](docs/05-data-switching.md)).

## build_runner komutları
```bash
dart run build_runner build --delete-conflicting-outputs   # tek seferlik
dart run build_runner watch --delete-conflicting-outputs   # geliştirirken
```
> Üretilen dosyalar (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`) repoya
> commit **edilmez**; lokalde ve CI'da üretilir.

## Mimari kararların gerekçeleri
- **Clean Architecture (Data/Domain/Presentation):** test edilebilirlik ve katman izolasyonu;
  Domain saf Dart. Detay: [`docs/02-architecture.md`](docs/02-architecture.md).
- **fpdart `Either<Failure,T>`:** hatalar tip düzeyinde taşınır, çağıran ele almaya zorlanır.
- **injectable `@Environment`:** mock/remote repository seçimi başlangıçta çözülür → tek komutla geçiş.
- **GeoJSON + Symbol Layer:** binlerce uçak için performanslı tek-katman çizim.

## Dokümantasyon
- Tüm planlama/karar dokümanları: [`docs/`](docs/README.md)
- Firebase yapılandırması & Security Rules: [`FIREBASE_README.md`](FIREBASE_README.md)

## Lisans
Bu depo bir işe alım study case'i olarak hazırlanmıştır.
