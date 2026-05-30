# 07 — Harita (MapLibre GL)

## Motor & tile
- `maplibre_gl` `MapLibreMap` widget'ı.
- Tile/style: **MapTiler** ücretsiz, **koyu** stil (radar estetiği). Style URL anahtar içerir:
  `https://api.maptiler.com/maps/<style>/style.json?key=<MAPTILER_KEY>` → key `.env`'den
  (`MAPTILER_KEY`). Anahtar yoksa MapLibre demo/açık stil ile graceful degrade.

## Uçakların çizimi — GeoJSON + Symbol Layer (zorunlu yaklaşım)
Marker'lar tek tek widget olarak DEĞİL, performanslı şekilde tek bir kaynak+katman ile çizilir:

1. Uçak listesi → **GeoJSON Point FeatureCollection**:
   ```json
   { "type":"FeatureCollection", "features":[
     { "type":"Feature",
       "geometry":{"type":"Point","coordinates":[lon,lat]},
       "properties":{"icao24":"...","callsign":"...","bearing":<true_track>} } ] }
   ```
2. `style.addSource(...)` ile **GeoJSON source** eklenir; yenilemede `setGeoJsonSource` ile veri
   güncellenir (kaynak yeniden yaratılmaz).
3. `style.addImage('plane', <assets/images/plane.png bytes>)` ile uçak ikonu yüklenir.
4. **Symbol Layer**:
   - `iconImage = 'plane'`
   - `iconRotate = ['get','bearing']` → her uçak `true_track` açısına döner
   - `iconRotationAlignment = 'map'`, `iconAllowOverlap = true`, `iconSize` ölçek.

## Bilgi kartı (Bottom Sheet)
- Symbol layer'a tıklama → `onFeatureTapped`/feature query ile `icao24` alınır.
- İlgili `FlightEntity` bulunur → `showModalBottomSheet`:
  - **Callsign**, **menşe ülke**, **irtifa (ft)**, **hız (km/h)**, **yerde/havada** durumu.
- Birim dönüşümleri `core/utils/unit_converters.dart`:
  - `metersToFeet(m) = m * 3.28084`
  - `mpsToKmh(v) = v * 3.6`

## Konum butonu
- FAB → `permission_handler` ile konum izni iste → `geolocator` ile konum al →
  `mapController.animateCamera(CameraUpdate.newLatLng(...))`.
- İzin reddi/servis kapalı → `LocationFailure` → bilgilendirici SnackBar.

## Yenileme
- `flightsProvider` periyodik (Timer/`Stream.periodic`) `getStates()` çağırır
  (`AppConfig.refreshInterval`). Her güncellemede yalnızca GeoJSON source güncellenir.
- Yenileme sırasında hata → fallback akışı (bkz. [05](05-data-switching.md)).

## Android notları
- `maplibre_gl` minSdk ≥ 21; projede minSdk **23** (Firebase ile uyumlu).
- Konum izinleri `AndroidManifest.xml`: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
  ağ erişimi için `INTERNET`.
