# 08 — Firebase (Auth + Firestore)

> Kurulum adımlarının kullanıcıya dönük özeti kök `FIREBASE_README.md`'dedir. Bu dosya
> mimari/şema kararlarını içerir.

## Authentication
- Yöntem: **E-posta / Şifre** (`firebase_auth`).
- Kayıt akışı: `createUserWithEmailAndPassword` → başarıda Firestore `users/{uid}` dokümanı
  oluştur (Ad Soyad, e-posta, kayıt tarihi).
- Giriş akışı: `signInWithEmailAndPassword`.
- **Beni Hatırlat:** Firebase oturum kalıcılığı zaten cihazda tutulur; "Beni Hatırlat" işaretli
  değilse çıkışta/oturum başında ek temizleme yapılır. Tercih `shared_preferences`'ta saklanır.
- Çıkış: `signOut`.

## Firestore — şema
Koleksiyon: **`users`**, doküman id = **`uid`**.
```
users/{uid} {
  fullName:  string
  email:     string
  createdAt: timestamp   // serverTimestamp()
}
```
- Profil ekranı bu dokümanı okur; "Ad Soyad" düzenleme → yalnızca `fullName` update.
- `createdAt` yalnızca oluşturuluşta yazılır, update'lerde dokunulmaz.

## Security Rules (`firestore.rules`)
İlke: **kullanıcı yalnızca kendi dokümanını** okuyup yazabilir.
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null
                    && request.auth.uid == userId
                    && request.resource.data.keys().hasOnly(['fullName','email','createdAt']);
      allow update: if request.auth != null
                    && request.auth.uid == userId
                    && request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['fullName']);
      allow delete: if false;
    }
    match /{document=**} { allow read, write: if false; }
  }
}
```
Mantık:
- `read`: sadece sahibi.
- `create`: doc id == uid ve yalnızca beklenen alanlar.
- `update`: sadece `fullName` değiştirilebilir (e-posta/kayıt tarihi kurcalanamaz).
- `delete`: kapalı; diğer tüm yollar kapalı (default-deny).

## Kurulum (kullanıcı)
1. Firebase Console'da proje oluştur, **Email/Password** sağlayıcısını aç.
2. `flutterfire configure` → `lib/firebase_options.dart` + `android/app/google-services.json`
   (ikisi de gitignore).
3. `firebase deploy --only firestore:rules` ile kuralları yayınla.
4. Değerlendiriciye **Viewer** yetkisi ver (e-posta teslim sonrası gelecek).
