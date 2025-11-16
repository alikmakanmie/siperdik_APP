// lib/core/models/ppid_model.dart

class PpidModel {
  final int id;
  final int userId;
  final String nama;
  final String divisi;
  final String kategoriInformasi;
  final List<String>? jenisInformasi;
  final String? filePdf;
  final String? fileWord;
  final String? thumbnail;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PpidModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.divisi,
    required this.kategoriInformasi,
    this.jenisInformasi,
    this.filePdf,
    this.fileWord,
    this.thumbnail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PpidModel.fromJson(Map<String, dynamic> json) {
    // ✅ FIX: Handle both String and Array for jenis_informasi
    List<String>? parseJenisInformasi(dynamic value) {
      if (value == null) {
        return null;
      } else if (value is String) {
        // Jika string, convert ke array
        return value.isEmpty ? null : [value];
      } else if (value is List) {
        // Jika array, convert semua ke String
        return value.map((e) => e.toString()).toList();
      }
      return null;
    }

    return PpidModel(
      id: json['id'],
      userId: json['user_id'],
      nama: json['nama'],
      divisi: json['divisi'],
      kategoriInformasi: json['kategori_informasi'],
      jenisInformasi: parseJenisInformasi(json['jenis_informasi']),
      filePdf: json['file_pdf'],
      fileWord: json['file_word'],
      thumbnail: json['thumnail'],  // Typo di database: 'thumnail'
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'divisi': divisi,
      'kategori_informasi': kategoriInformasi,
      'jenis_informasi': jenisInformasi,
      'file_pdf': filePdf,
      'file_word': fileWord,
      'thumnail': thumbnail,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
