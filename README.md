# OtoBakım Defteri

OtoBakım Defteri, araç bakım ve masraf kayıtlarını takip etmek için Flutter ve SQLite ile geliştirilmiş mobil final projesidir.

## Proje Amacı

Bu uygulama, kullanıcıların araçlarını, bakım geçmişlerini ve araç masraflarını yerel SQLite veritabanında düzenli şekilde takip etmelerini sağlar.

## Kullanılan Teknolojiler

- Dart
- Flutter
- SQLite
- sqflite
- path

## Temel Özellikler

- Araç ekleme, listeleme, düzenleme ve silme
- Bakım kaydı ekleme, listeleme, düzenleme ve silme
- Masraf kaydı ekleme, listeleme, düzenleme ve silme
- Araç bazlı bakım ve masraf takibi
- Dashboard üzerinde araç sayısı, bakım toplamı, masraf toplamı ve genel toplam gösterimi
- Form validasyonları
- Silme işlemleri için onay pencereleri
- İşlem sonuçları için SnackBar mesajları
- SQLite ile yerel veri saklama
- Özel uygulama ikonu ve açılış ekranı

## Uygulama Ekranları

- Splash / Giriş ekranı
- Ana dashboard ekranı
- Araçlarım ekranı
- Araç ekleme / düzenleme ekranı
- Araç detay ekranı
- Bakım kayıtları ekranı
- Bakım ekleme / düzenleme ekranı
- Masraf kayıtları ekranı
- Masraf ekleme / düzenleme ekranı
- Hakkında ekranı

## Proje Klasör Yapısı

```text
lib/
  database/
    database_helper.dart
  models/
    vehicle.dart
    maintenance_record.dart
    expense_record.dart
  pages/
    splash_page.dart
    home_page.dart
    vehicles_page.dart
    vehicle_form_page.dart
    vehicle_detail_page.dart
    maintenance_records_page.dart
    maintenance_form_page.dart
    expense_records_page.dart
    expense_form_page.dart
    about_page.dart
  widgets/
    app_summary_card.dart
    empty_state.dart
    vehicle_card.dart
    maintenance_card.dart
    expense_card.dart
    section_title.dart
```

## Veritabanı Yapısı

Uygulamada üç ana tablo kullanılır:

- vehicles
- maintenance_records
- expense_records

vehicles tablosu araç bilgilerini tutar.  
maintenance_records tablosu araçlara ait bakım kayıtlarını tutar.  
expense_records tablosu araçlara ait masraf kayıtlarını tutar.

## Kurulum ve Çalıştırma

```bash
flutter pub get
flutter run
```

## Test ve Kontrol

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Ders Bilgisi

Bu proje, EFC304 Mobil Uygulama Tasarımı ve Geliştirme dersi final projesi kapsamında hazırlanmıştır.

## Not

Bu uygulama internet bağlantısı veya harici backend kullanmaz. Veriler cihaz üzerinde SQLite veritabanında saklanır.
