# 09 — UI Tasarım Sistemi (Radar / Kokpit)

## Tema yönü
Koyu, havacılık/radar esintili bir arayüz. Harita ekranı yıldız; koyu harita üzerinde parlak
turkuaz uçak işaretleri ve cam (glass) bilgi kartları.

## Renk paleti (`core/theme/app_colors.dart`)
| Token | Hex | Kullanım |
|---|---|---|
| `background` | `#0A0E14` | App zemin (koyu lacivert-siyah) |
| `surface` | `#121A24` | Kart/sheet |
| `surfaceVariant` | `#1B2735` | İkincil yüzey, input |
| `primary` | `#22D3EE` | Turkuaz vurgu (radar) |
| `primaryDim` | `#0E7490` | Basılı/disabled vurgu |
| `accent` | `#7C5CFF` | İkincil aksiyon |
| `onSurface` | `#E6EDF3` | Birincil metin |
| `onSurfaceMuted` | `#8696A7` | İkincil metin |
| `success` | `#34D399` | Havada/pozitif |
| `warning` | `#FBBF24` | Mock veri / uyarı |
| `error` | `#F87171` | Hata |
| `outline` | `#243240` | Kenarlık/ayraç |

## Tipografi (`app_text_styles.dart`)
- Başlık/teknik veriler için mono-esinli okunur font; gövde için sistem fontu.
- ScreenUtil ile `.sp`: displayLarge, titleLarge, bodyMedium, labelSmall vb.

## Ortak widget kütüphanesi (`core/widgets/`) — zorunlu
UI'da **hardcoded renk/spacing yok**; her şey tema + bu widget'lardan gelir.
- `AppScaffold` — tutarlı arka plan + (ops.) AppBar.
- `AppButton` — primary/secondary/ghost varyant, loading durumu.
- `AppTextField` — label, hata, secure (şifre) modu, validator entegrasyonu.
- `LoadingOverlay` — radar tarama animasyonlu yükleme.
- `AppErrorView` — `Failure` mesajı + "Tekrar dene" (`onRetry`).
- `EmptyView` — boş durum illüstrasyonu + mesaj.
- `GlassCard` — bilgi kartı/sheet için yarı saydam yüzey.
- `MockDataBanner` — mock moddayken üstte ince uyarı şeridi.

## Ekranlar
1. **Login** — gradient hero (radar grid) + cam form kartı, e-posta/şifre, "Beni Hatırlat", Kayıt'a link.
2. **Register** — Ad Soyad, e-posta, şifre, şifre tekrar; inline validasyon.
3. **Flight Map (ana)** — tam ekran koyu harita, sağ altta konum FAB, üstte (mock'ta) `MockDataBanner`.
4. **Flight Info Sheet** — callsign başlık, ülke, irtifa (ft), hız (km/h), durum chip'i (Havada/Yerde).
5. **Profile** — avatar/baş harf, Ad Soyad (düzenlenebilir), e-posta, kayıt tarihi, Çıkış butonu.
6. **Shell** — alt 2 sekme: Harita / Profil (auto_route `AutoTabsScaffold`).

## Durumlar
Her veri ekranı 4 durumu ele alır: **loading → data / empty / error**. Riverpod state
`AsyncValue`/freezed union üzerinden; UI `LoadingOverlay`/`EmptyView`/`AppErrorView`'a düşer.

## Responsive
`flutter_screenutil` `designSize` ile referans (örn. 390×844); tüm ölçüler `.w/.h/.r/.sp`.
