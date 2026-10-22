import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ProfilMahasiswaApp());
}

// ============================================================
// TAMPILAN (warna, gradasi, tema)
// ============================================================

class Tampilan {
  Tampilan._();

  static const Color utama = Color(0xFF4F46E5);
  static const double radius = 24;
  static const EdgeInsets halaman = EdgeInsets.all(20);

  /// Kartu profil saat status aktif.
  static const LinearGradient gradAktif = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Kartu profil saat status tidak aktif.
  static const LinearGradient gradNonaktif = LinearGradient(
    colors: [Color(0xFF475569), Color(0xFF64748B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData _buatTema(Brightness brightness) {
  final cs = ColorScheme.fromSeed(
    seedColor: Tampilan.utama,
    brightness: brightness,
  );
  final bentukTombol = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      titleTextStyle: TextStyle(
        color: cs.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: bentukTombol,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: bentukTombol,
      ),
    ),
  );
}

// ============================================================
// APP + ROUTES + LIFECYCLE
// ============================================================

/// Nama route dibuat sederhana dan terpusat di satu tempat.
class Routes {
  Routes._();

  static const String beranda = '/';
  static const String profil = '/profil';
  static const String kontak = '/kontak';
  static const String detailMatkul = '/detail-matkul';
}

/// Widget akar. Memegang ViewModel selama aplikasi hidup dan mencatat
/// siklus hidup aplikasi (lihat Debug Console dengan awalan [SiklusHidup]).
class ProfilMahasiswaApp extends StatefulWidget {
  const ProfilMahasiswaApp({super.key});

  @override
  State<ProfilMahasiswaApp> createState() => _ProfilMahasiswaAppState();
}

class _ProfilMahasiswaAppState extends State<ProfilMahasiswaApp>
    with WidgetsBindingObserver {
  late final ProfilViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfilViewModel();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[SiklusHidup] initState');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // resumed, inactive, hidden, paused, detached
    debugPrint('[SiklusHidup] $state');
  }

  @override
  void dispose() {
    debugPrint('[SiklusHidup] dispose');
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.beranda:
        return MaterialPageRoute<void>(
          builder: (_) => const BerandaScreen(),
          settings: settings,
        );
      case Routes.profil:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfilScreen(),
          settings: settings,
        );
      case Routes.kontak:
        return MaterialPageRoute<void>(
          builder: (_) => const KontakScreen(),
          settings: settings,
        );
      case Routes.detailMatkul:
      // Data dikirim seperlunya: cukup kode mata kuliah.
        final kode = settings.arguments as String?;
        return MaterialPageRoute<void>(
          builder: (_) => DetailMatkulScreen(kode: kode),
          settings: settings,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfilScope(
      viewModel: _viewModel,
      child: MaterialApp(
        title: 'Profil Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: _buatTema(Brightness.light),
        darkTheme: _buatTema(Brightness.dark),
        themeMode: ThemeMode.system,
        initialRoute: Routes.beranda,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

// ============================================================
// MODEL + DATA MATA KULIAH
// ============================================================

/// Data profil yang sudah disimpan pengguna.
class Profil {
  const Profil({
    required this.nama,
    required this.nim,
    required this.kelas,
    required this.prodi,
    required this.isAktif,
    this.foto,
  });

  final String nama;
  final String nim;
  final String kelas;
  final String prodi;
  final bool isAktif;
  final Uint8List? foto;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Profil &&
              other.nama == nama &&
              other.nim == nim &&
              other.kelas == kelas &&
              other.prodi == prodi &&
              other.isAktif == isAktif &&
              other.foto == foto;

  @override
  int get hashCode => Object.hash(nama, nim, kelas, prodi, isAktif, foto);
}

/// Data kontak yang sudah disimpan pengguna.
class Kontak {
  const Kontak({
    required this.email,
    required this.noHp,
    required this.github,
  });

  final String email;
  final String noHp;
  final String github;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Kontak &&
              other.email == email &&
              other.noHp == noHp &&
              other.github == github;

  @override
  int get hashCode => Object.hash(email, noHp, github);
}

/// Satu mata kuliah untuk layar Beranda dan Detail.
class MataKuliah {
  const MataKuliah({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.deskripsi,
  });

  final String kode;
  final String nama;
  final int sks;
  final String deskripsi;
}

/// Data mata kuliah. Kode singkat dipakai untuk badge dan argumen route.
class SampleData {
  SampleData._();

  static const List<MataKuliah> daftarMatkul = [
    MataKuliah(
      kode: 'SMBD',
      nama: 'Sistem Manajemen Basis Data',
      sks: 3,
      deskripsi:
      'Pengelolaan sistem basis data: arsitektur DBMS, perancangan, optimasi kueri, transaksi, dan keamanan data.',
    ),
    MataKuliah(
      kode: 'TAB',
      nama: 'Teknologi Aplikasi Bergerak',
      sks: 3,
      deskripsi:
      'Teknologi pengembangan aplikasi mobile: platform, arsitektur aplikasi, dan layanan pendukung aplikasi bergerak.',
    ),
    MataKuliah(
      kode: 'PK',
      nama: 'Penalaran Komputer',
      sks: 3,
      deskripsi:
      'Konsep penalaran dan kecerdasan buatan: representasi pengetahuan, logika, dan pemecahan masalah dengan komputer.',
    ),
    MataKuliah(
      kode: 'SGK',
      nama: 'Simulasi dan Game Komputer',
      sks: 3,
      deskripsi:
      'Konsep simulasi dan pengembangan game: pemodelan, mesin game, dan perancangan permainan.',
    ),
    MataKuliah(
      kode: 'KRP',
      nama: 'Kriptografi',
      sks: 3,
      deskripsi:
      'Dasar kriptografi: enkripsi simetris dan asimetris, fungsi hash, tanda tangan digital, dan penerapannya.',
    ),
    MataKuliah(
      kode: 'PPI',
      nama: 'Penulisan dan Publikasi Ilmiah',
      sks: 2,
      deskripsi:
      'Teknik menulis karya ilmiah: struktur artikel, sitasi dan referensi, serta proses publikasi jurnal.',
    ),
    MataKuliah(
      kode: 'JN',
      nama: 'Jaringan Nirkabel',
      sks: 3,
      deskripsi:
      'Konsep jaringan nirkabel: standar WLAN, topologi, keamanan, dan manajemen jaringan nirkabel.',
    ),
    MataKuliah(
      kode: 'PAB',
      nama: 'Pemrograman Aplikasi Bergerak',
      sks: 3,
      deskripsi:
      'Membangun aplikasi mobile: UI, state, navigasi, lifecycle, dan pengelolaan state dengan ViewModel.',
    ),
  ];
}

// ============================================================
// VIEWMODEL + SCOPE
// ============================================================

/// ViewModel: menyimpan state, menerima event dari UI, dan menjalankan logic.
/// Setiap perubahan memanggil [notifyListeners] sehingga UI di-build ulang.
class ProfilViewModel extends ChangeNotifier {
  // ---- draft form profil (yang sedang diketik) ----
  String _nama = '';
  String _nim = '';
  String _kelas = '';
  String _prodi = 'Informatika';
  bool _isAktif = true;
  Uint8List? _foto;

  // Pesan error baru ditampilkan setelah tombol Simpan ditekan.
  bool _showErrors = false;

  // Profil yang sudah disimpan (tampil di Beranda).
  Profil? _savedProfil;

  // ---- draft form kontak ----
  String _email = '';
  String _noHp = '';
  String _github = '';
  bool _showKontakErrors = false;
  Kontak? _savedKontak;

  String get nama => _nama;
  String get nim => _nim;
  String get kelas => _kelas;
  String get prodi => _prodi;
  bool get isAktif => _isAktif;
  Uint8List? get foto => _foto;
  bool get showErrors => _showErrors;
  Profil? get savedProfil => _savedProfil;

  String get email => _email;
  String get noHp => _noHp;
  String get github => _github;
  Kontak? get savedKontak => _savedKontak;

  List<MataKuliah> get daftarMatkul => SampleData.daftarMatkul;

  // ---- nilai turunan profil: dihitung dari state sehingga selalu konsisten ----
  String? get namaError => _nama.trim().isEmpty ? 'Nama wajib diisi' : null;

  String? get nimError {
    final nim = _nim.trim();
    if (nim.isEmpty) return 'NIM wajib diisi';
    if (!RegExp(r'^\d+$').hasMatch(nim)) return 'NIM hanya boleh berisi angka';
    return null;
  }

  String? get kelasError => _kelas.trim().isEmpty ? 'Kelas wajib diisi' : null;

  String? get prodiError =>
      _prodi.trim().isEmpty ? 'Program studi wajib diisi' : null;

  bool get isFormValid =>
      namaError == null &&
          nimError == null &&
          kelasError == null &&
          prodiError == null;

  Profil get draftProfil => Profil(
    nama: _nama.trim(),
    nim: _nim.trim(),
    kelas: _kelas.trim(),
    prodi: _prodi.trim(),
    isAktif: _isAktif,
    foto: _foto,
  );

  bool get adaPerubahan => _savedProfil != draftProfil;

  /// Error hanya dimunculkan jika pengguna sudah mencoba menyimpan.
  String? errorTampil(String? error) => _showErrors ? error : null;

  // ---- nilai turunan kontak ----
  String? get emailError {
    final email = _email.trim();
    if (email.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? get noHpError {
    final hp = _noHp.trim();
    if (hp.isEmpty) return 'Nomor HP wajib diisi';
    if (!RegExp(r'^\+?\d{9,15}$').hasMatch(hp)) {
      return 'Nomor HP tidak valid (9-15 angka)';
    }
    return null;
  }

  /// GitHub bersifat opsional: kosong dianggap valid.
  String? get githubError {
    final gh = _github.trim();
    if (gh.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(gh)) {
      return 'Hanya huruf, angka, dan tanda hubung';
    }
    return null;
  }

  bool get isKontakValid =>
      emailError == null && noHpError == null && githubError == null;

  Kontak get draftKontak => Kontak(
    email: _email.trim(),
    noHp: _noHp.trim(),
    github: _github.trim(),
  );

  bool get adaPerubahanKontak => _savedKontak != draftKontak;

  String? errorKontakTampil(String? error) => _showKontakErrors ? error : null;

  /// Jumlah kolom kontak yang terisi pada kontak tersimpan (0 sampai 3).
  int get jumlahKontakTerisi {
    final kontak = _savedKontak;
    if (kontak == null) return 0;
    return [kontak.email, kontak.noHp, kontak.github]
        .where((nilai) => nilai.isNotEmpty)
        .length;
  }

  MataKuliah? cariMatkul(String? kode) {
    for (final matkul in daftarMatkul) {
      if (matkul.kode == kode) return matkul;
    }
    return null;
  }

  // ---- event dari form Profil ----
  void onNamaChange(String value) {
    _nama = value;
    notifyListeners();
  }

  void onNimChange(String value) {
    _nim = value;
    notifyListeners();
  }

  void onKelasChange(String value) {
    _kelas = value;
    notifyListeners();
  }

  void onProdiChange(String value) {
    _prodi = value;
    notifyListeners();
  }

  void onAktifChange(bool value) {
    _isAktif = value;
    notifyListeners();
  }

  /// Isi null untuk menghapus foto.
  void onFotoChange(Uint8List? value) {
    _foto = value;
    notifyListeners();
  }

  /// Mengembalikan true jika berhasil disimpan.
  bool simpanProfil() {
    if (isFormValid) {
      _showErrors = false;
      _savedProfil = draftProfil;
      notifyListeners();
      return true;
    }
    _showErrors = true;
    notifyListeners();
    return false;
  }

  // ---- event dari layar Kontak ----
  void onEmailChange(String value) {
    _email = value;
    notifyListeners();
  }

  void onNoHpChange(String value) {
    _noHp = value;
    notifyListeners();
  }

  void onGithubChange(String value) {
    _github = value;
    notifyListeners();
  }

  /// Mengembalikan true jika berhasil disimpan.
  bool simpanKontak() {
    if (isKontakValid) {
      _showKontakErrors = false;
      _savedKontak = draftKontak;
      notifyListeners();
      return true;
    }
    _showKontakErrors = true;
    notifyListeners();
    return false;
  }
}

/// Menyediakan [ProfilViewModel] ke seluruh widget di bawahnya.
/// Widget yang memanggil [ProfilScope.of] otomatis di-build ulang
/// setiap kali ViewModel memanggil notifyListeners().
class ProfilScope extends InheritedNotifier<ProfilViewModel> {
  const ProfilScope({
    super.key,
    required ProfilViewModel viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  static ProfilViewModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProfilScope>();
    assert(scope != null, 'ProfilScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}

// ============================================================
// LAYAR 1: BERANDA
// ============================================================

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = ProfilScope.of(context);
    final profil = vm.savedProfil;
    final kontak = vm.savedKontak;
    final tema = Theme.of(context);
    final totalSks =
    vm.daftarMatkul.fold<int>(0, (jumlah, matkul) => jumlah + matkul.sks);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: ListView(
        padding: Tampilan.halaman,
        children: [
          Text(
            '${_sapaan()},',
            style: tema.textTheme.bodyLarge
                ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
          Text(
            profil == null ? 'Mahasiswa' : _namaDepan(profil.nama),
            style: tema.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (profil == null)
            const _KartuKosong()
          else
            _KartuProfil(
              label: 'KARTU MAHASISWA',
              nama: profil.nama,
              nim: profil.nim,
              kelas: profil.kelas,
              prodi: profil.prodi,
              isAktif: profil.isAktif,
              foto: profil.foto,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.profil),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(profil == null ? 'Isi Profil' : 'Ubah Profil'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.kontak),
                  icon: const Icon(Icons.contact_phone_outlined),
                  label: const Text('Kontak'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.menu_book_outlined,
                  nilai: '${vm.daftarMatkul.length}',
                  label: 'Mata kuliah',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.schedule_outlined,
                  nilai: '$totalSks',
                  label: 'Total SKS',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.contacts_outlined,
                  nilai: '${vm.jumlahKontakTerisi}/3',
                  label: 'Kontak',
                ),
              ),
            ],
          ),
          if (kontak != null) ...[
            const SizedBox(height: 24),
            _JudulBagian('Kontak'),
            const SizedBox(height: 12),
            _Kartu(
              child: _DaftarKontak(
                email: kontak.email,
                noHp: kontak.noHp,
                github: kontak.github,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _JudulBagian('Mata Kuliah'),
          const SizedBox(height: 12),
          for (final matkul in vm.daftarMatkul)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Kartu(
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: tema.colorScheme.primaryContainer,
                    foregroundColor: tema.colorScheme.onPrimaryContainer,
                    child: Text(
                      matkul.kode,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    matkul.nama,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${matkul.sks} SKS'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.detailMatkul,
                    arguments: matkul.kode,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// LAYAR 2: FORM PROFIL (+ FOTO PROFIL)
// ============================================================

enum _StatusSimpan {
  belum(Icons.info_outline, 'Belum disimpan', Colors.blueGrey),
  berubah(Icons.edit_note, 'Ada perubahan yang belum disimpan', Colors.orange),
  tersimpan(Icons.check_circle, 'Tersimpan ✓', Colors.green);

  const _StatusSimpan(this.ikon, this.teks, this.warna);

  final IconData ikon;
  final String teks;
  final Color warna;
}

/// Form profil. Alur:
/// UI menampilkan state -> pengguna memicu event -> ViewModel mengubah state
/// -> widget di-build ulang (rebuild) -> tampilan ikut berubah.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  void _simpan(BuildContext context, ProfilViewModel vm) {
    FocusScope.of(context).unfocus();
    final berhasil = vm.simpanProfil();
    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan')),
      );
    }
  }

  /// Membuka kamera/galeri lalu menyimpan hasilnya (bytes) di ViewModel.
  Future<void> _ambilFoto(
      BuildContext context,
      ProfilViewModel vm,
      ImageSource sumber,
      ) async {
    try {
      final file = await ImagePicker().pickImage(
        source: sumber,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null) return; // pengguna membatalkan
      final bytes = await file.readAsBytes();
      vm.onFotoChange(bytes);
    } catch (e) {
      debugPrint('[Foto] gagal mengambil foto: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat mengambil foto. Coba lagi.')),
      );
    }
  }

  void _pilihSumberFoto(BuildContext context, ProfilViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari kamera'),
              onTap: () {
                Navigator.pop(sheetContext);
                _ambilFoto(context, vm, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(sheetContext);
                _ambilFoto(context, vm, ImageSource.gallery);
              },
            ),
            if (vm.foto != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Hapus foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  vm.onFotoChange(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ProfilScope.of(context);

    final status = vm.savedProfil == null
        ? _StatusSimpan.belum
        : vm.adaPerubahan
        ? _StatusSimpan.berubah
        : _StatusSimpan.tersimpan;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Profil')),
      body: SingleChildScrollView(
        padding: Tampilan.halaman,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu pratinjau: berubah langsung mengikuti state (rebuild).
            _KartuProfil(
              label: 'PRATINJAU',
              nama: vm.nama,
              nim: vm.nim,
              kelas: vm.kelas,
              prodi: vm.prodi,
              isAktif: vm.isAktif,
              foto: vm.foto,
            ),
            const SizedBox(height: 24),
            _JudulBagian('Foto Profil'),
            const SizedBox(height: 12),
            _PilihFoto(
              foto: vm.foto,
              onTap: () => _pilihSumberFoto(context, vm),
            ),
            const SizedBox(height: 24),
            _JudulBagian('Data Diri'),
            const SizedBox(height: 12),
            _FormField(
              label: 'Nama lengkap',
              hint: 'Contoh: Budi Santoso',
              icon: Icons.person_outline,
              initialValue: vm.nama,
              onChanged: vm.onNamaChange,
              errorText: vm.errorTampil(vm.namaError),
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'NIM',
              hint: 'Hanya angka',
              icon: Icons.badge_outlined,
              initialValue: vm.nim,
              onChanged: vm.onNimChange,
              errorText: vm.errorTampil(vm.nimError),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Kelas',
              hint: 'Contoh: IFB5J',
              icon: Icons.class_outlined,
              initialValue: vm.kelas,
              onChanged: vm.onKelasChange,
              errorText: vm.errorTampil(vm.kelasError),
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Program studi',
              icon: Icons.school_outlined,
              initialValue: vm.prodi,
              onChanged: vm.onProdiChange,
              errorText: vm.errorTampil(vm.prodiError),
            ),
            const SizedBox(height: 24),
            _JudulBagian('Status'),
            const SizedBox(height: 12),
            _Kartu(
              child: SwitchListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: const Text(
                  'Mahasiswa aktif',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Warna kartu pratinjau mengikuti status'),
                value: vm.isAktif,
                onChanged: vm.onAktifChange,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _simpan(context, vm),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan Profil'),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _BarisStatus(key: ValueKey(status), status: status),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar besar untuk memilih foto profil. Ketuk untuk menambah/mengganti.
class _PilihFoto extends StatelessWidget {
  const _PilihFoto({required this.foto, required this.onTap});

  final Uint8List? foto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bytes = foto;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  backgroundImage: bytes == null ? null : MemoryImage(bytes),
                  child: bytes == null
                      ? const Icon(Icons.person_outline, size: 52)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onTap,
            child: Text(bytes == null ? 'Tambah foto profil' : 'Ganti foto'),
          ),
        ],
      ),
    );
  }
}

class _BarisStatus extends StatelessWidget {
  const _BarisStatus({super.key, required this.status});

  final _StatusSimpan status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(status.ikon, size: 20, color: status.warna),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            status.teks,
            style: TextStyle(
              color: status.warna,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    required this.errorText,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ============================================================
// LAYAR 3: DETAIL MATA KULIAH
// ============================================================

class DetailMatkulScreen extends StatelessWidget {
  const DetailMatkulScreen({super.key, required this.kode});

  final String? kode;

  @override
  Widget build(BuildContext context) {
    final matkul = ProfilScope.of(context).cariMatkul(kode);
    final tema = Theme.of(context);

    if (matkul == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Mata Kuliah')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 56, color: tema.colorScheme.outline),
                const SizedBox(height: 12),
                const Text('Mata kuliah tidak ditemukan.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mata Kuliah')),
      body: SingleChildScrollView(
        padding: Tampilan.halaman,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: Tampilan.gradAktif,
                borderRadius: BorderRadius.circular(Tampilan.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Text(
                      matkul.kode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    matkul.nama,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(
                        icon: Icons.schedule_outlined,
                        teks: '${matkul.sks} SKS',
                      ),
                      _Pill(icon: Icons.tag, teks: matkul.kode),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Kartu(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _JudulBagian('Deskripsi'),
                    const SizedBox(height: 8),
                    Text(
                      matkul.deskripsi,
                      style: tema.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LAYAR 4: KONTAK (layar tambahan)
// ============================================================

class KontakScreen extends StatelessWidget {
  const KontakScreen({super.key});

  void _simpan(BuildContext context, ProfilViewModel vm) {
    FocusScope.of(context).unfocus();
    final berhasil = vm.simpanKontak();
    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontak berhasil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ProfilScope.of(context);
    final tema = Theme.of(context);

    final status = vm.savedKontak == null
        ? _StatusSimpan.belum
        : vm.adaPerubahanKontak
        ? _StatusSimpan.berubah
        : _StatusSimpan.tersimpan;

    return Scaffold(
      appBar: AppBar(title: const Text('Kontak')),
      body: SingleChildScrollView(
        padding: Tampilan.halaman,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cantumkan kontak yang bisa dihubungi.',
              style: tema.textTheme.bodyLarge
                  ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _JudulBagian('Pratinjau'),
            const SizedBox(height: 12),
            _Kartu(
              child: _DaftarKontak(
                email: vm.email,
                noHp: vm.noHp,
                github: vm.github,
              ),
            ),
            const SizedBox(height: 24),
            _JudulBagian('Data Kontak'),
            const SizedBox(height: 12),
            _FormField(
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.email_outlined,
              initialValue: vm.email,
              onChanged: vm.onEmailChange,
              errorText: vm.errorKontakTampil(vm.emailError),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Nomor HP / WhatsApp',
              hint: 'Contoh: 081234567890',
              icon: Icons.phone_outlined,
              initialValue: vm.noHp,
              onChanged: vm.onNoHpChange,
              errorText: vm.errorKontakTampil(vm.noHpError),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Username GitHub (opsional)',
              hint: 'Contoh: budisantoso',
              icon: Icons.code,
              initialValue: vm.github,
              onChanged: vm.onGithubChange,
              errorText: vm.errorKontakTampil(vm.githubError),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _simpan(context, vm),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan Kontak'),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _BarisStatus(key: ValueKey(status), status: status),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiga baris kontak (email, HP, GitHub). Dipakai di Beranda dan layar Kontak.
class _DaftarKontak extends StatelessWidget {
  const _DaftarKontak({
    required this.email,
    required this.noHp,
    required this.github,
  });

  final String email;
  final String noHp;
  final String github;

  @override
  Widget build(BuildContext context) {
    final gh = github.trim();

    return Column(
      children: [
        _BarisKontak(
          icon: Icons.email_outlined,
          label: 'Email',
          nilai: email.trim(),
        ),
        const Divider(height: 1),
        _BarisKontak(
          icon: Icons.phone_outlined,
          label: 'Nomor HP / WhatsApp',
          nilai: noHp.trim(),
        ),
        const Divider(height: 1),
        _BarisKontak(
          icon: Icons.code,
          label: 'GitHub',
          nilai: gh.isEmpty ? '' : '@$gh',
        ),
      ],
    );
  }
}

class _BarisKontak extends StatelessWidget {
  const _BarisKontak({
    required this.icon,
    required this.label,
    required this.nilai,
  });

  final IconData icon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        nilai.isEmpty ? '-' : nilai,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(label),
    );
  }
}

// ============================================================
// KOMPONEN BERSAMA
// ============================================================

/// "Budi Santoso" -> "BS", "Budi" -> "B", kosong -> "?".
String _inisial(String nama) {
  final bagian = nama
      .trim()
      .split(RegExp(r'\s+'))
      .where((kata) => kata.isNotEmpty)
      .toList();
  if (bagian.isEmpty) return '?';
  if (bagian.length == 1) return bagian.first[0].toUpperCase();
  return (bagian.first[0] + bagian.last[0]).toUpperCase();
}

String _namaDepan(String nama) {
  final bagian = nama.trim().split(RegExp(r'\s+'));
  return bagian.first.isEmpty ? 'Mahasiswa' : bagian.first;
}

String _sapaan() {
  final jam = DateTime.now().hour;
  if (jam < 11) return 'Selamat pagi';
  if (jam < 15) return 'Selamat siang';
  if (jam < 18) return 'Selamat sore';
  return 'Selamat malam';
}

class _JudulBagian extends StatelessWidget {
  const _JudulBagian(this.teks);

  final String teks;

  @override
  Widget build(BuildContext context) {
    return Text(
      teks,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

/// Kartu netral dengan garis tepi tipis (dipakai daftar, switch, deskripsi).
class _Kartu extends StatelessWidget {
  const _Kartu({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

/// Label kecil berlatar transparan, dipakai di atas kartu bergradasi.
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.teks});

  final IconData icon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            teks,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu profil bergradasi. Warna berubah mengikuti [isAktif] dengan animasi.
/// Jika [foto] ada, avatar menampilkan foto; jika tidak, menampilkan inisial.
class _KartuProfil extends StatelessWidget {
  const _KartuProfil({
    required this.label,
    required this.nama,
    required this.nim,
    required this.kelas,
    required this.prodi,
    required this.isAktif,
    this.foto,
  });

  final String label;
  final String nama;
  final String nim;
  final String kelas;
  final String prodi;
  final bool isAktif;
  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final bytes = foto;
    final namaTampil = nama.trim().isEmpty ? '(nama belum diisi)' : nama.trim();
    final prodiTampil = prodi.trim().isEmpty ? '-' : prodi.trim();
    final nimTampil = nim.trim().isEmpty ? '-' : nim.trim();
    final kelasTampil = kelas.trim().isEmpty ? '-' : kelas.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isAktif ? Tampilan.gradAktif : Tampilan.gradNonaktif,
        borderRadius: BorderRadius.circular(Tampilan.radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white24,
                backgroundImage: bytes == null ? null : MemoryImage(bytes),
                child: bytes == null
                    ? Text(
                  _inisial(nama),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaTampil,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prodiTampil,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(icon: Icons.badge_outlined, teks: 'NIM $nimTampil'),
              _Pill(icon: Icons.class_outlined, teks: 'Kelas $kelasTampil'),
              _Pill(
                icon: isAktif
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
                teks: isAktif ? 'Aktif' : 'Tidak aktif',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tampilan Beranda saat profil belum disimpan.
class _KartuKosong extends StatelessWidget {
  const _KartuKosong();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: Tampilan.gradAktif,
        borderRadius: BorderRadius.circular(Tampilan.radius),
      ),
      child: const Column(
        children: [
          Icon(Icons.account_circle_outlined, size: 56, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Profil belum diisi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Lengkapi data dirimu agar kartu mahasiswa muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.nilai,
    required this.label,
  });

  final IconData icon;
  final String nilai;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return _Kartu(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: tema.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              nilai,
              style: tema.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: tema.textTheme.bodySmall
                  ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}