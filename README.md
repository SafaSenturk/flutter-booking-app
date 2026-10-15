<div align="center">

<img src="docs/banner.png" alt="Glow Studio – Flutter appointment booking app" width="100%" />

# Glow Studio · Flutter Appointment Booking

A booking app for salons, barbers, clinics and studios: customers pick a service, a specialist and a free time on a live calendar; the owner approves or declines requests from an admin panel. Double bookings are impossible — enforced by the database, not just the UI.

[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![State](https://img.shields.io/badge/state-flutter__bloc%209-13B9FD)](https://bloclibrary.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20·%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![CI](https://github.com/SafaSenturk/flutter-booking-app/actions/workflows/ci.yml/badge.svg)](https://github.com/SafaSenturk/flutter-booking-app/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**[⬇️ Download the APK](https://github.com/SafaSenturk/flutter-booking-app/releases/latest)** · [🇹🇷 Türkçe açıklama](#-türkçe)

</div>

---

## Demo

<p align="center">
  <img src="docs/demo.gif" alt="Booking a hair colouring appointment, then approving it from the salon panel" width="300" />
</p>

<p align="center"><i>Pick a service → specialist → day → free time → request → the salon approves → the customer is notified.</i></p>

## Features

**For customers**
- Service menu by category with duration and price, plus the team with ratings
- **Choose a specialist** or "any" (the first one who is free is assigned)
- **Date strip** for the next 30 days — closed days (Sunday) are greyed out
- **Live availability:** time slots are calculated from opening hours, service length and existing bookings, and update in real time — if someone takes your slot while you look, it disappears
- Optional note for the salon, booking request with an animated confirmation
- **My appointments:** upcoming / past, status (pending, confirmed, declined, cancelled, completed), **cancel up to 2 hours before**
- **Notification** when the salon confirms or declines

**For the salon owner**
- **Requests** with Approve / Decline, live badge on the tab
- **Daily schedule** timeline across all staff, "mark done" after the visit
- Today's stats: requests, confirmed bookings, expected revenue

**Try the owner side yourself:** in *Profile*, switch on **"Try the salon panel"**. You then manage **your own** bookings as if you were the owner — other customers' data is never visible (enforced by the security rules).

**General**
- Email/password and Google sign-in, password reset
- Turkish / English
- Works on any business with appointments: hairdressers, barbers, beauty and nail studios, clinics, physiotherapists, tutors, consultants…

## Screenshots

| Sign in | Services | Specialist & date | Live time slots |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/01_sign_in.jpg" width="200"/> | <img src="docs/screenshots/02_home.jpg" width="200"/> | <img src="docs/screenshots/03_service.jpg" width="200"/> | <img src="docs/screenshots/04_times.jpg" width="200"/> |
| **Request sent** | **My appointments** | **Owner: requests** | **Owner: schedule** |
| <img src="docs/screenshots/05_requested.jpg" width="200"/> | <img src="docs/screenshots/06_appointments.jpg" width="200"/> | <img src="docs/screenshots/07_owner_requests.jpg" width="200"/> | <img src="docs/screenshots/08_owner_schedule.jpg" width="200"/> |
| **Demo owner mode** | **Profile** | **Turkish** | **Turkish** |
| <img src="docs/screenshots/09_demo_owner.jpg" width="200"/> | <img src="docs/screenshots/10_profile.jpg" width="200"/> | <img src="docs/screenshots/11_home_tr.jpg" width="200"/> | <img src="docs/screenshots/12_booking_tr.jpg" width="200"/> |

## How double booking is prevented

Each booked 30-minute block is a document `slots/{staff}_{yyyyMMdd}_{HHmm}`. Booking runs in a **Firestore transaction** that checks every block of the service, then writes the appointment and its slots together. The **security rules** only allow *creating* a slot (never overwriting one), require the slot id to match its staff/day/time, and check that it belongs to an appointment of the same user — so even a modified client cannot double-book or book for someone else.

```
users/{uid}          name, email, phone, role (customer | admin), demoOwner
services/{id}        nameEn, nameTr, category, durationMin, price      ← read-only in the app
staff/{id}           name, roleEn, roleTr, rating, services[]          ← read-only in the app
appointments/{id}    uid, serviceId, staffId, start, durationMin, price,
                     status (pending → confirmed / declined / cancelled → completed), note, slotIds[]
slots/{staff_day_time}  uid, appointmentId
```

| Who | Can do |
|---|---|
| Customer | create own *pending* bookings, read own bookings, cancel own upcoming ones |
| Owner (`role: admin`) | read all bookings, confirm / decline / complete, free slots |
| Customer in demo owner mode | the owner actions — on their own bookings only |
| Nobody in the app | change their role, edit the catalog |

These rules are covered by **13 tests on the Firebase Emulator** ([`rules-tests/`](rules-tests/rules.test.js)).

## Tech stack

| Area | Choice |
|---|---|
| App | Flutter 3.44, Material 3, custom serif/sans design (DM Serif Display + DM Sans) |
| State management | **flutter_bloc 9** — Cubits per feature, `bloc_test` + `mocktail` |
| Backend | Firebase Auth (email, Google), Cloud Firestore (transactions, real-time queries), security rules |
| Notifications | `flutter_local_notifications` on booking status changes |
| Localization | ARB + `gen-l10n`, Turkish & English |
| CI | GitHub Actions: analyze, unit/bloc tests, security-rule tests |

## Project structure

```
lib/
├── main.dart                   # Firebase, repositories, global cubits
├── core/                       # theme, formatting, shared widgets, notifications
├── data/                       # models, Auth / Catalog / Booking repositories
├── domain/availability.dart    # pure slot logic (opening hours, lead time, overlaps)
├── features/
│   ├── auth/                   # AuthCubit + sign in / sign up
│   ├── catalog/                # services & team
│   ├── booking/                # BookingCubit, booking flow, confirmation
│   ├── appointments/           # my bookings, cancel
│   ├── admin/                  # owner panel: requests & schedule
│   ├── profile/                # profile, language, demo owner mode
│   └── home/                   # bottom navigation shell
└── l10n/
tool/seed_catalog.py            # seeds services & staff
rules-tests/                    # Firestore rules tests (emulator)
firestore.rules · firestore.indexes.json
```

## Run it yourself

```bash
git clone https://github.com/SafaSenturk/flutter-booking-app.git
cd flutter-booking-app
flutter pub get
flutter run
```

```bash
flutter test                          # availability logic + cubits (13 tests)
cd rules-tests && npm ci && npm test  # security rules on the emulator (needs Java)
```

To use your own Firebase project: enable Email/Password and Google sign-in, run `flutterfire configure`, `firebase deploy --only firestore`, then `python tool/seed_catalog.py <project-id>`. Make an account the owner by setting `role: "admin"` on its `users` document in the console.

---

## 🇹🇷 Türkçe

**Glow Studio**, kuaför, berber, güzellik salonu, klinik gibi randevuyla çalışan işletmeler için bir randevu uygulamasıdır. Müşteri hizmeti, uzmanı ve **canlı takvimden** boş saati seçer; işletme sahibi talepleri **yönetici panelinden onaylar ya da reddeder**.

**Müşteri tarafı**
- Kategorili hizmet listesi (süre ve fiyat), ekip ve puanları
- Uzman seçimi ya da "fark etmez" (ilk müsait uzman atanır)
- 30 günlük tarih şeridi, kapalı günler pasif
- **Canlı müsaitlik:** boş saatler çalışma saatleri, hizmet süresi ve mevcut randevulara göre hesaplanır, anlık güncellenir
- Randevularım (yaklaşan / geçmiş), durum etiketleri, **2 saat öncesine kadar iptal**
- Salon onaylayınca ya da reddedince **bildirim**

**İşletme sahibi tarafı**
- Bekleyen talepler: **Onayla / Reddet**
- Tüm çalışanların **günlük takvimi**, "tamamlandı" işaretleme
- Günün özeti: talep sayısı, onaylı randevu, beklenen ciro

**Çift rezervasyon imkânsız:** her 30 dakikalık dilim ayrı bir kayıt; rezervasyon Firestore işlemiyle (transaction) yapılır ve güvenlik kuralları aynı dilimin ikinci kez alınmasını engeller. Kurallar emülatörde **13 testle** doğrulanır.

**Denemek için:** [Releases](https://github.com/SafaSenturk/flutter-booking-app/releases/latest) sayfasından APK'yı indir, hesap oluştur ve randevu al. Sonra *Profil → "Salon panelini dene"* seçeneğini açarak kendi randevularını işletme sahibi gibi onaylayabilirsin.

İşletmen için kendi markanla bir randevu uygulaması mı istiyorsun? **[safasenturk.github.io](https://safasenturk.github.io)**

---

<div align="center">

Built by **[Safa Şentürk](https://github.com/SafaSenturk)** · Flutter Mobile Developer · [Portfolio](https://safasenturk.github.io)

<sub>Glow Studio, its team and address are fictional and used for demonstration only.</sub>

</div>
