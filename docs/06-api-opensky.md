# 06 — OpenSky Network API

## Kimlik doğrulama — OAuth2 Client Credentials
OpenSky artık **OAuth2 Client Credentials** akışı kullanır (Basic Auth kullanımdan kalktı).

- Token endpoint:
  `https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token`
- İstek: `grant_type=client_credentials`, `client_id`, `client_secret` (form-urlencoded).
- Cevap: `access_token` (Bearer) + `expires_in` (~30 dk).
- İstemci kimlik bilgileri OpenSky hesabından alınır ve **`.env`**'e yazılır:
  ```
  OPENSKY_CLIENT_ID=...
  OPENSKY_CLIENT_SECRET=...
  ```

### AuthInterceptor davranışı
1. İstek öncesi: geçerli (süresi dolmamış) token varsa `Authorization: Bearer <token>` ekler;
   yoksa token alır. Token **secure storage**'da süresiyle birlikte cache'lenir.
2. `401` cevabında: token'ı geçersiz kıl, **bir kez** yenile ve isteği tekrar dene; yine 401 ise
   `AuthFailure`'a yol açacak şekilde hatayı yükselt.

## Veri endpoint'i — States
- `GET https://opensky-network.org/api/states/all`
- Opsiyonel bbox: `?lamin&lomin&lamax&lomax` (kredi tasarrufu için harita görünümüne göre).
- Cevap: `{ "time": <int>, "states": [ [ ...17 alan... ], ... ] }` — her uçak bir **dizi**.

### Kritik alan indeksleri (state vector)
| idx | alan | tip | not |
|---|---|---|---|
| 0 | `icao24` | String | benzersiz id |
| 1 | `callsign` | String? | trim edilir |
| 2 | `origin_country` | String | menşe ülke |
| 5 | `longitude` | double? | null → atlanır |
| 6 | `latitude` | double? | null → atlanır |
| 7 | `baro_altitude` | double? | metre |
| 8 | `on_ground` | bool | yerde/havada |
| 9 | `velocity` | double? | m/s |
| 10 | `true_track` | double? | derece (0=kuzey) → marker rotasyonu |
| 13 | `geo_altitude` | double? | metre (irtifa gösterimi) |

`FlightStateDto.fromJson` bu pozisyonel diziyi okur (custom `fromJson`), `toEntity()` ile
`FlightEntity`'ye dönüşür. Konumu (lat/lon) null olan uçaklar elenir.

## Hata → Failure eşlemesi
| HTTP / durum | Failure |
|---|---|
| 401 | `AuthFailure` (token/credential) |
| 429 | `RateLimitFailure` (kredi/limit) |
| timeout / bağlantı yok | `NetworkFailure` |
| 5xx / diğer | `ServerFailure` |

`RetryInterceptor`: 429'da sınırlı sayıda exponential backoff; tükenince `RateLimitFailure`.

## Kredi yönetimi
- Günlük 4.000 kredi. Bbox'lı sorgu daha az kredi harcar.
- Presentation yenileme aralığı makul tutulur (örn. 15–30 sn) — `AppConfig.refreshInterval`.
