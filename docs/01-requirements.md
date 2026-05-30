# 01 — Gereksinimler (Bound'lar)

Kaynak: PITON Technology "SkyTracker" Study Case dokümanı (v1.0). Bu dosya, kabul kriterlerinin
tek referansıdır; her faz buradaki maddelere göre doğrulanır.

## Proje
Gerçek zamanlı uçuş verilerini harita üzerinde takip eden bir simülasyon. Beklenen: modern
yazılım prensiplerine sadık, **her hata senaryosunu** (network kesintisi, API limit aşımı vb.)
yönetebilen yüksek kaliteli bir mobil uygulama.

## 1. Zorunlu teknolojiler
Aşağıdaki yığın **zorunludur**. Sapma yalnızca gerekçelendirilip dokümante edilirse değerlendirilir
(bu projede sapma yoktur).

- Framework: **Flutter (Stable)**
- State: **hooks_riverpod + flutter_hooks**
- Mimari: **Clean Architecture**
- DI: **get_it + injectable**
- Routing: **auto_route**
- HTTP: **dio** (interceptor önerilir)
- Harita: **MapLibre GL**
- Auth/DB: **Firebase Auth + Cloud Firestore**
- Kod üretimi: **freezed + json_serializable**
- Fonksiyonel: **fpdart** (Either & Option)
- Lokalizasyon: **easy_localization** (TR + EN)
- Responsive: **flutter_screenutil**

## 2. API — OpenSky Network
- Doküman: https://openskynetwork.github.io/opensky-api/rest.html
- Kayıt: https://opensky-network.org (ücretsiz)
- Auth: **OAuth2 Client Credentials (Bearer Token)**
- Limit: günlük 4.000 kredi (kayıtlı kullanıcı)
- Kritik alanlar: `icao24, callsign, longitude, latitude, velocity, true_track, geo_altitude`

## 3. Mimari beklenti
Data / Domain / Presentation katmanlarına **sıkı** bağlılık; klasör yapısı bunu yansıtmalı.
**Kritik:** Tüm veri akışı `Either<Failure, T>` ile sarmalanır; hata yönetimi merkezîdir.

## 4. Fonksiyonel isterler
### a. Kayıt & Giriş
- Kayıt: Ad Soyad, E-posta, Şifre, Şifre Tekrar → başarı sonrası Firestore `users` koleksiyonu.
- Giriş: Firebase Auth (e-posta/şifre) + **"Beni Hatırlat"**.
- Validasyon: e-posta formatı, şifre uzunluğu, boş alan kontrolü.

### b. Mock Data & Environment (kritik)
- `assets/mock/flights_mock.json` — OpenSky çıktısıyla **birebir** uyumlu.
- `IFlightRepository` → `FlightRemoteRepository` (gerçek) + `FlightMockRepository` (yerel).
- **Environment switch:** bootstrap'ta injectable üzerinden hangi repo'nun kullanılacağı belirlenir.
  Beklenti: **tek satır / flavor ile** tüm app mock'a geçebilmeli.
- **Hata toleransı (artı puan):** 401/429'da kullanıcıyı bilgilendir + mock'a geçme opsiyonu (veya otomatik).

### c. Uçuş Haritası (kritik ekran)
- MapLibre GL + ücretsiz tile (MapTiler vb.).
- Uçaklar marker; her marker uçak ikonu, `true_track` açısına göre **döndürülmüş**.
- Performans: **GeoJSON Point FeatureCollection** + **Symbol Layer**.
- Bilgi kartı: marker'a tıkla → **Bottom Sheet** (callsign, menşe ülke, irtifa, hız, yerde/havada).
- Birim dönüşümü: irtifa **m→ft**, hız **m/s→km/h**.
- **Konum butonu:** haritayı cihaz konumuna ortalar.

### d. Profil
- Firestore'dan Ad Soyad, E-posta, Kayıt Tarihi.
- Ad Soyad düzenleme (Firestore yazma).
- Çalışan **Çıkış Yap**.

### e. Bottom Navigation
- 2 sekme: **Harita** (ana) + **Profil**.

### f. Firebase
- Auth (e-posta/şifre), Firestore (profil), **Security Rules** (yalnızca sahibi kendi verisini okur/yazar).

## 5. Dokümantasyon
- Kök `README.md`: kurulum, mimari kararların gerekçeleri, build_runner komutları.
- `FIREBASE_README.md`: Firebase yapılandırması + Security Rules mantığı.
- Demo: çalışan APK + kısa video.

## 6. Teslim
- **Public** GitHub reposu (tüm kod geçmişi + dokümanlar).
- Değerlendiriciye Firebase **Viewer / QA** yetkisi.
- README + APK + video repoda.
- Link → hr@piton.com.tr.

## Kabul kontrol listesi (özet)
- [ ] Zorunlu stack eksiksiz ve doğru kullanılıyor
- [ ] Tüm repo/usecase dönüşleri `Either<Failure, T>`
- [ ] Mock/Remote switch tek komutla çalışıyor
- [ ] 401/429 fallback davranışı mevcut
- [ ] Harita: Symbol Layer + true_track rotasyon + bottom sheet + birim dönüşümü + konum butonu
- [ ] Auth + Firestore profil (düzenleme dahil) + Security Rules
- [ ] TR/EN lokalizasyon
- [ ] README + FIREBASE_README + APK + video
- [ ] Public repo, anlamlı commit geçmişi
