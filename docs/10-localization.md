# 10 — Lokalizasyon (TR + EN)

## Paket & kurulum
- `easy_localization`.
- Çeviri dosyaları: `assets/translations/en.json`, `assets/translations/tr.json`.
- `main()`/`bootstrap`: `EasyLocalization.ensureInitialized()`, `MaterialApp` `EasyLocalization`
  ile sarılır: `supportedLocales: [Locale('tr'), Locale('en')]`, `fallbackLocale: Locale('en')`,
  `path: 'assets/translations'`.

## Anahtar düzeni (namespaced)
```
auth.login.title, auth.login.email, auth.login.password, auth.login.rememberMe,
auth.register.title, auth.register.fullName, auth.register.confirmPassword,
validation.emailInvalid, validation.passwordTooShort, validation.required,
map.locationButton, map.mockBanner, map.refreshing,
flight.callsign, flight.country, flight.altitude, flight.speed, flight.status.onGround,
flight.status.airborne, flight.unit.feet, flight.unit.kmh,
profile.title, profile.fullName, profile.email, profile.registeredAt, profile.edit,
profile.save, profile.logout,
error.server, error.network, error.auth, error.rateLimit, error.cache,
error.location, error.unknown, common.retry, common.cancel, common.switchToMock
```

## Kullanım
- UI metinleri `'auth.login.title'.tr()`; parametreli: `.tr(namedArgs: {...})`.
- `Failure` → i18n key eşlemesi `failure_mapper` üzerinden (bkz. [02](02-architecture.md)).
- Dil değiştirme (ops.): Profil'de `context.setLocale(...)`.

## Kural
Hiçbir kullanıcıya görünür metin koda gömülü olmaz; hepsi çeviri dosyalarından gelir. Yeni
metin eklenince **hem** `tr.json` **hem** `en.json` güncellenir (eksik anahtar CI'da yakalanır).
