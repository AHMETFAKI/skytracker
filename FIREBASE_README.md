# Firebase Kurulumu & Security Rules

> Bu doküman, SkyTracker'ın Firebase yapılandırmasını ve Security Rules mantığını açıklar.
> Mimari/şema kararları için [`docs/08-firebase.md`](docs/08-firebase.md).

## 1. Proje oluşturma
1. [Firebase Console](https://console.firebase.google.com) → yeni proje.
2. **Authentication → Sign-in method → Email/Password** sağlayıcısını etkinleştir.
3. **Firestore Database** oluştur (production mode; kurallar aşağıda).

## 2. Uygulamaya bağlama
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Bu komut şunları üretir (ikisi de **gitignore**'dadır, repoya girmez):
- `lib/firebase_options.dart`
- `android/app/google-services.json`

## 3. Firestore veri modeli
```
users/{uid} {
  fullName:  string      // kayıt + profilde düzenlenebilir
  email:     string      // kayıt anında, değiştirilemez
  createdAt: timestamp   // serverTimestamp(), değiştirilemez
}
```

## 4. Security Rules
Kural dosyası: [`firestore.rules`](firestore.rules). İlke: **kullanıcı yalnızca kendi
dokümanını** okur/yazar; `fullName` dışındaki alanlar update'te kilitli; silme kapalı; diğer
tüm yollar default-deny.

Yayınlama:
```bash
firebase deploy --only firestore:rules
```

## 5. Değerlendirici erişimi
Firestore veri yapısı ve kuralların incelenebilmesi için ilgili e-posta adresine **Viewer
(Görüntüleyici)** / **Firebase QA** yetkisi verilecektir (adres teslim sonrası iletilecek).

---
*Bu dosya Faz 5 ve Faz 9'da gerçek değerlerle güncellenecektir.*
