# SkyTracker

[![CI](https://github.com/AHMETFAKI/skytracker/actions/workflows/ci.yml/badge.svg)](https://github.com/AHMETFAKI/skytracker/actions/workflows/ci.yml)

OpenSky Network'ün canlı uçuş verisini MapLibre haritası üzerinde gösteren bir
Flutter uygulaması. PITON Technology study case'i olarak yazıldı.

Uçaklar haritada gerçek yönlerine (`true_track`) dönmüş ikonlarla görünür ve
veri yenilemeleri arasında kayarak hareket eder. Bir uçağa dokununca callsign,
menşe ülke, irtifa, hız, dikey hız ve yön bilgisini gösteren bir kart açılır.
Giriş/kayıt Firebase Auth ile, profil Firestore'da tutulur. Tek bir bayrakla
uygulama mock veri ile gerçek API arasında geçer.

Kurulabilir APK ve kısa demo videosu:
[Releases](https://github.com/AHMETFAKI/skytracker/releases/latest).

## Öne çıkanlar

- Harita: GeoJSON kaynağı + Symbol Layer, irtifaya göre renklenen ikonlar,
  düşük zoom'da kümeleme, seçili uçak için halka ve rota çizgisi.
- Mock / Remote veri kaynağı; remote 401/429 dönerse otomatik mock'a düşer.
- Firebase Auth (e-posta/şifre, "beni hatırla") ve Firestore profil.
- Birim ve yenileme aralığı ayarları, TR/EN dil desteği.
- Clean Architecture, hata akışı `Either<Failure, T>` üzerinden.

## Gereksinimler

- Flutter (stable) / Dart 3.11+. Proje Flutter 3.41 ile geliştirildi.
- Android tarafında JDK 21 — `maplibre_gl` native kaynaklarını 21 ile derliyor.
- Çalıştırmak için anahtar gerekmez; uygulama varsayılan olarak repodaki mock
  veriyle açılır.

## Kurulum

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

build_runner; freezed, json_serializable, injectable ve auto_route çıktılarını
üretir. Bu üretilen dosyalar (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`,
`*.config.dart`) repoya commit edilmez; her klonda ve CI'da yeniden üretilir.
Yeni bir model, route ya da injectable ekleyince komutu tekrar çalıştırın, ya da
geliştirirken `dart run build_runner watch --delete-conflicting-outputs` açık
bırakın.

### .env

Repoda `.env` yok; gerçek anahtarlar paylaşılmıyor. Şablondan kopyalayın:

```bash
cp .env.example .env
```

Mock modda `.env`'i boş bırakabilirsiniz. Gerçek veri ve MapTiler'ın koyu harita
stili için içindeki anahtarları doldurun:

- `OPENSKY_CLIENT_ID` / `OPENSKY_CLIENT_SECRET` — opensky-network.org üzerinden
  ücretsiz hesap (OAuth2 client credentials).
- `MAPTILER_KEY` — maptiler.com. Boş kalırsa açık demo stiline düşülür; harita
  yine çalışır, sadece koyu radar görünümü gitmiş olur.

### Firebase (giriş için, opsiyonel)

Giriş/kayıt ve profil Firebase'e bağlı, yapılandırması da repoda yok:

```bash
flutterfire configure
```

Bu komut `lib/firebase_options.dart` ve `android/app/google-services.json`
dosyalarını üretir (ikisi de gitignore'lu). Bu dosyalar yoksa uygulama çökmez:
Firebase'i atlar, harita mock veriyle çalışmaya devam eder, sadece auth ve
profil devre dışı kalır. Firestore şeması ve güvenlik kuralları için
[FIREBASE_README.md](FIREBASE_README.md).

## Çalıştırma

```bash
flutter run   # kaynak: .env'deki DATA_SOURCE (yoksa mock)
```

Veri kaynağını iki yoldan seçebilirsiniz:

- `.env` içindeki `DATA_SOURCE=mock|remote` satırı — kalıcı tercih.
- Çalıştırırken `--dart-define`, ki `.env`'i geçersiz kılar:

```bash
flutter run --dart-define=DATA_SOURCE=remote   # gerçek OpenSky verisi
```

Öncelik: `--dart-define=DATA_SOURCE` > `.env`'deki `DATA_SOURCE` > `mock`.
injectable bu değere göre başlangıçta mock veya remote repository'yi bağlar;
remote için `.env`'e OpenSky anahtarları gerekir. Ayrıntı:
[docs/05-data-switching.md](docs/05-data-switching.md).

## Test

```bash
flutter analyze   # uyarısız
flutter test      # 57 test
```

## CI ve APK

Her push ve PR'da GitHub Actions çalışır: `pub get` → `build_runner` →
`analyze` → `test` → `flutter build apk --debug`. Debug APK secret olmadan,
mock-first derlenir; `google-services` eklentisi yalnızca dosya mevcutsa
devreye girer. Ayrıntı: [docs/11-ci-cd.md](docs/11-ci-cd.md).

Release paketi:

```bash
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

APK ve AAB repoya konmaz. Kurulabilir paket ve demo videosu Releases sayfasında.

## Mimari

Katmanlar data / domain / presentation olarak ayrılmış; domain saf Dart, Flutter
ya da transport detayına bağımlı değil. Veri akışı `Either<Failure, T>` ile
sarılı, böylece hatalar tip seviyesinde taşınır ve çağıran tarafı ele almaya
zorlanır. Uçaklar tek bir GeoJSON kaynağı ve Symbol Layer ile çizilir; binlerce
nokta tek katmanda kalır. Karar gerekçelerinin tamamı [docs/](docs/README.md)
altında.

## Lisans

Bu repo bir işe alım study case'i olarak hazırlanmıştır.
