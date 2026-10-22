# Profil Mahasiswa

Aplikasi Flutter untuk tugas Form Profil Mahasiswa (State, Event, Navigation, dan ViewModel).

Dibuat oleh: Dimas Putra Wijaya (NIM 2411031, kelas IFB5J)

## Fitur
- Beranda: kartu mahasiswa, ringkasan, dan daftar mata kuliah
- Form Profil: nama, NIM, kelas, program studi, status aktif, foto profil (kamera atau galeri), validasi, dan pratinjau langsung
- Detail Mata Kuliah: data dikirim lewat argumen route
- Kontak: email, nomor HP, dan username GitHub dengan validasi

## Konsep yang dipakai
- State dan event: `ProfilViewModel` (`ChangeNotifier`) dibagikan lewat `ProfilScope` (`InheritedNotifier`). UI di-build ulang setiap `notifyListeners()` dipanggil.
- Navigasi: named routes dengan `onGenerateRoute`.
- Lifecycle: `WidgetsBindingObserver` dengan log berawalan `[SiklusHidup]`.

## Menjalankan
Jalankan `flutter pub get`, lalu `flutter run`.

## Dependensi tambahan
- `image_picker` untuk mengambil foto profil