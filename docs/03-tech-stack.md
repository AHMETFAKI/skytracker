# 03 — Teknoloji Yığını ve Gerekçeler

Tüm paketler dokümandaki **zorunlu** listeden gelir. Aşağıda her birinin **neden** ve
**nerede** kullanıldığı belgelenmiştir. Sürümler `pubspec.yaml`'da sabitlenir.

## Runtime bağımlılıkları
| Paket | Rol | Nerede |
|---|---|---|
| `flutter_hooks` | Widget-içi yerel state (controller, lifecycle) | Tüm sayfalar |
| `hooks_riverpod` | DI-dostu, test edilebilir state yönetimi | Provider'lar, app kökü `ProviderScope` |
| `get_it` | Service locator | `core/di` |
| `injectable` | get_it kaydını anotasyonla üretir; `@Environment` ile mock/remote | DataSource/Repository kayıtları |
| `auto_route` | Tip-güvenli, kod-üretimli routing + guard | `core/router`, shell + tab'lar |
| `dio` | HTTP istemcisi + interceptor zinciri | `core/network`, OpenSky |
| `maplibre_gl` | Açık kaynak vektör harita motoru | Flights presentation |
| `firebase_core` | Firebase init | `bootstrap.dart` |
| `firebase_auth` | E-posta/şifre kimlik doğrulama | auth feature |
| `cloud_firestore` | Kullanıcı profili kalıcılığı | auth/profile feature |
| `freezed_annotation` | Immutable model/union (Entity, DTO, State, Failure) | tüm katmanlar |
| `json_annotation` | JSON (de)serialization anotasyonları | DTO'lar |
| `fpdart` | `Either`/`Option` fonksiyonel yapılar | repo/usecase imzaları |
| `easy_localization` | TR/EN runtime lokalizasyon | `MaterialApp` + tüm metinler |
| `flutter_screenutil` | Ekran-bağımsız ölçekleme (`.w/.h/.sp/.r`) | tüm UI |
| `geolocator` | Cihaz konumu | konum butonu |
| `permission_handler` | Konum izni yönetimi | konum butonu |
| `shared_preferences` | "Beni Hatırlat" bayrağı + hafif cache | auth |
| `flutter_secure_storage` | OAuth token / hassas veri | OpenSky token cache |
| `flutter_dotenv` | `.env`'den secret + `DATA_SOURCE` okuma | `bootstrap.dart` |

## Geliştirme (dev) bağımlılıkları
| Paket | Rol |
|---|---|
| `build_runner` | Kod üretimi orkestrasyonu |
| `freezed` | freezed generator |
| `json_serializable` | toJson/fromJson generator |
| `injectable_generator` | get_it kayıt generator |
| `auto_route_generator` | route generator |
| `flutter_lints` | Lint kuralları (`analysis_options.yaml`) |
| `mocktail` *(test)* | Repository/DataSource mock'lama |

## Notlar / kararlar
- **Riverpod (hooks_riverpod):** Notifier tabanlı provider'lar; `flutter_hooks` ile birlikte
  `HookConsumerWidget`. Manuel kod-üretimsiz Notifier veya `riverpod_generator` opsiyonel.
- **injectable `@Environment`:** mock/remote repo seçimini derleme/başlangıç anında çözer —
  spec'in "tek satır/flavor ile mock" beklentisini karşılar (bkz. [05](05-data-switching.md)).
- **Secrets:** `.env` git'e girmez; repoda `.env.example` bulunur. Firebase `flutterfire`
  çıktısı (`firebase_options.dart`, `google-services.json`) de gitignore'dadır.
- **Generated dosyalar** (`*.g.dart/*.freezed.dart/*.gr.dart/*.config.dart`) commit edilmez;
  CI ve lokalde `build_runner` ile üretilir (bkz. [11](11-ci-cd.md)).
