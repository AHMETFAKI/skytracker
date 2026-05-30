# 00 — Yol Haritası

Proje 10 fazda ilerler. **Her faz = bir (veya birkaç) conventional commit + push.**
Durum sütunu ilerledikçe güncellenir.

| Faz | Konu | Commit mesajı | Durum |
|---|---|---|---|
| 0 | Repo & docs iskeleti | `chore: project docs & repo setup` | ✅ |
| 1 | Bağımlılıklar & yapı | `chore: dependencies & project skeleton` | ✅ |
| 2 | Core katman | `feat: core layer (error, network, di, router, theme)` | ✅ |
| 3 | Flights domain + data | `feat: flights data layer + mock/remote switching` | ✅ |
| 4 | Harita ekranı | `feat: flight map screen` | ✅ |
| 5 | Auth & Firestore | `feat: auth & firestore profile` | ✅ |
| 6 | Shell + Profil | `feat: shell navigation & profile screen` | ✅ |
| 7 | Lokalizasyon & cila | `feat: localization & ui polish` | ✅ |
| 8 | CI/CD & test | `ci: github actions + unit tests` | ✅ |
| 9 | Teslim | `docs: delivery readme + apk` | 🟡 |

> 🟡 Faz 9: Teslim dokümanları (README + FIREBASE_README) finalize edildi ve repo public.
> Release APK üretimi (lokal Gradle loopback kısıtı) ile demo videosu kullanıcı tarafında tamamlanır.

## Faz çıktıları (özet)

- **Faz 0:** Temiz git deposu, public GitHub repo, tüm `docs/*.md`, kök README iskeleti.
- **Faz 1:** `pubspec.yaml` (tüm zorunlu paketler), `analysis_options.yaml`, klasör iskeleti,
  Android minSdk 23, `bootstrap.dart` + `main.dart`, easy_localization & ScreenUtil kurulumu.
- **Faz 2:** `Failure`/Exception hiyerarşisi, `dio` + interceptor'lar, `injectable` DI,
  `auto_route` router, radar teması, dönüşüm/validator util'leri, ortak widget kütüphanesi.
- **Faz 3:** `FlightEntity`, `IFlightRepository`, DTO, `FlightMockRepository` +
  `FlightRemoteRepository`, OpenSky OAuth2 istemcisi, `flights_mock.json`, `DATA_SOURCE` switch.
- **Faz 4:** MapLibre haritası, GeoJSON Symbol Layer, `true_track` rotasyonu, bilgi kartı
  (Bottom Sheet), konum butonu, birim dönüşümleri, periyodik yenileme, fallback UX.
- **Faz 5:** Kayıt/Giriş + validasyon + "Beni Hatırlat", Firestore `users` koleksiyonu, rules.
- **Faz 6:** 2 sekmeli BottomNav, Profil görüntüle/düzenle/çıkış, `AuthGuard`.
- **Faz 7:** TR/EN tam çeviri, responsive geçiş, loading/empty/error durum widget'ları.
- **Faz 8:** GitHub Actions (analyze + test + build apk), birim testleri.
- **Faz 9:** Kök README + FIREBASE_README finalize, APK, demo videosu, repo public.

## Açık bağımlılıklar (kullanıcı girdisi)
- Firebase projesi + `flutterfire configure`.
- OpenSky OAuth2 `client_id`/`client_secret`, MapTiler API key → `.env`.
- Demo videosu; değerlendiriciye Firebase **Viewer** yetkisi.
