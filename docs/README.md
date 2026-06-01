# SkyTracker — Dokümantasyon

Bu klasör projenin **teknik karar gerekçelerini** içerir: hangi paketin neden
seçildiği, mimarinin nasıl katmanlandığı, harita/Firebase/CI kurgusu.

> Kurulum ve çalıştırma adımları için kök dizindeki [`../README.md`](../README.md),
> Firebase yapılandırması için [`../FIREBASE_README.md`](../FIREBASE_README.md) dosyalarına bakın.

## İçindekiler

| # | Doküman | İçerik |
|---|---|---|
| 01 | [Gereksinimler](01-requirements.md) | Case'ten çıkarılan zorunlu isterler |
| 02 | [Mimari](02-architecture.md) | Clean Architecture, katmanlar, veri akışı, `Either` |
| 03 | [Teknoloji Yığını](03-tech-stack.md) | Her paket + gerekçe + nerede kullanıldığı |
| 05 | [Data Switching](05-data-switching.md) | Mock/Remote repo, environment switch, fallback |
| 06 | [OpenSky API](06-api-opensky.md) | OAuth2, endpoint'ler, alanlar, interceptor'lar |
| 07 | [Harita](07-map.md) | MapLibre, GeoJSON Symbol Layer, rotasyon, bottom sheet |
| 08 | [Firebase](08-firebase.md) | Auth, Firestore şeması, Security Rules |
| 09 | [UI Tasarım Sistemi](09-ui-design-system.md) | Radar/kokpit teması, renkler, ortak widget'lar |
| 10 | [Lokalizasyon](10-localization.md) | TR + EN, easy_localization |
| 11 | [CI/CD](11-ci-cd.md) | GitHub Actions pipeline |
