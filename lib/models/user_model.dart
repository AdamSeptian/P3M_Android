// lib/models/user_model.dart
class UserModel {
  final String uuid;
  final String username;
  final String email;
  final String role;
  final String status;
  final AnggotaModel? anggota;

  UserModel({
    required this.uuid,
    required this.username,
    required this.email,
    required this.role,
    required this.status,
    this.anggota,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    AnggotaModel? anggota;
    if (json['anggotas'] != null && (json['anggotas'] as List).isNotEmpty) {
      anggota = AnggotaModel.fromJson(json['anggotas'][0]);
    }
    return UserModel(
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      anggota: anggota,
    );
  }

  String get displayName => anggota?.namaLengkap ?? username;
  String get avatarUrl => anggota?.url ?? '';
}

class AnggotaModel {
  final String? namaLengkap;
  final String? gelar;
  final String? jabatan;
  final String? masaJabat;
  final String? instansi;
  final String? linkedin;
  final String? googleScholar;
  final String? scopus;
  final String? sinta;
  final String? image;
  final String? url;

  AnggotaModel({
    this.namaLengkap,
    this.gelar,
    this.jabatan,
    this.masaJabat,
    this.instansi,
    this.linkedin,
    this.googleScholar,
    this.scopus,
    this.sinta,
    this.image,
    this.url,
  });

  factory AnggotaModel.fromJson(Map<String, dynamic> json) => AnggotaModel(
    namaLengkap: json['nama_lengkap'],
    gelar: json['gelar'],
    jabatan: json['jabatan'],
    masaJabat: json['masa_jabat'],
    instansi: json['instansi'],
    linkedin: json['linkedin'],
    googleScholar: json['google_scholar'],
    scopus: json['scopus'],
    sinta: json['sinta'],
    image: json['image'],
    url: json['url'],
  );
}

// ─── BERITA MODEL ─────────────────────────────────────────────────────────────
class BeritaModel {
  final String uuid;
  final String judulBerita;
  final String isiBerita;
  final String status;
  final String image;
  final String url;
  final String? createdAt;
  final String? updatedAt;
  final String? username;
  final List<KategoriModel> kategoris;
  final List<TagModel> tags;

  BeritaModel({
    required this.uuid,
    required this.judulBerita,
    required this.isiBerita,
    required this.status,
    required this.image,
    required this.url,
    this.createdAt,
    this.updatedAt,
    this.username,
    this.kategoris = const [],
    this.tags = const [],
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) => BeritaModel(
    uuid: json['uuid'] ?? '',
    judulBerita: json['judul_berita'] ?? '',
    isiBerita: json['isi_berita'] ?? '',
    status: json['status'] ?? '',
    image: json['image'] ?? '',
    url: json['url'] ?? '',
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    username: json['user']?['username'],
    kategoris: (json['kategoris'] as List? ?? [])
        .map((k) => KategoriModel.fromJson(k)).toList(),
    tags: (json['tags'] as List? ?? [])
        .map((t) => TagModel.fromJson(t)).toList(),
  );
}

// ─── AGENDA MODEL ─────────────────────────────────────────────────────────────
class AgendaModel {
  final String uuid;
  final String namaKegiatan;
  final String tuanRumah;
  final String jadwal;
  final String status;
  final String file;
  final String url;
  final String? createdAt;
  final String? username;

  AgendaModel({
    required this.uuid,
    required this.namaKegiatan,
    required this.tuanRumah,
    required this.jadwal,
    required this.status,
    required this.file,
    required this.url,
    this.createdAt,
    this.username,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) => AgendaModel(
    uuid: json['uuid'] ?? '',
    namaKegiatan: json['nama_kegiatan'] ?? '',
    tuanRumah: json['tuan_rumah'] ?? '',
    jadwal: json['jadwal'] ?? '',
    status: json['status'] ?? '',
    file: json['file'] ?? '',
    url: json['url'] ?? '',
    createdAt: json['createdAt'],
    username: json['user']?['username'],
  );
}

// ─── KATEGORI MODEL ───────────────────────────────────────────────────────────
class KategoriModel {
  final String uuid;
  final String namaKategori;

  KategoriModel({required this.uuid, required this.namaKategori});

  factory KategoriModel.fromJson(Map<String, dynamic> json) => KategoriModel(
    uuid: json['uuid'] ?? '',
    namaKategori: json['nama_kategori'] ?? '',
  );

  Map<String, dynamic> toJson() => {'uuid': uuid, 'nama_kategori': namaKategori};

  @override
  bool operator ==(Object other) => other is KategoriModel && other.uuid == uuid;
  @override
  int get hashCode => uuid.hashCode;
}

// ─── TAG MODEL ────────────────────────────────────────────────────────────────
class TagModel {
  final String uuid;
  final String namaTag;

  TagModel({required this.uuid, required this.namaTag});

  factory TagModel.fromJson(Map<String, dynamic> json) => TagModel(
    uuid: json['uuid'] ?? '',
    namaTag: json['nama_tag'] ?? '',
  );

  Map<String, dynamic> toJson() => {'uuid': uuid, 'nama_tag': namaTag};

  @override
  bool operator ==(Object other) => other is TagModel && other.uuid == uuid;
  @override
  int get hashCode => uuid.hashCode;
}

// ─── DASHBOARD STATS ─────────────────────────────────────────────────────────
class DashboardStats {
  final int totalAnggota;
  final int totalAgenda;
  final int totalBerita;
  final int pendingUsers;
  final int pendingBerita;
  final int pendingAgenda;

  DashboardStats({
    this.totalAnggota = 0,
    this.totalAgenda = 0,
    this.totalBerita = 0,
    this.pendingUsers = 0,
    this.pendingBerita = 0,
    this.pendingAgenda = 0,
  });
}