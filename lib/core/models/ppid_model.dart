class PpidModel {
  final int id;
  final int userId;
  final String nama;
  final String divisi;
  final String kategoriInformasi;
  final String jenisInformasi;  // ✅ Tetap String
  final String? filePdf;
  final String? fileWord;
  final String? thumbnail;
  final String status;

  PpidModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.divisi,
    required this.kategoriInformasi,
    required this.jenisInformasi,
    this.filePdf,
    this.fileWord,
    this.thumbnail,
    required this.status,
  });

  factory PpidModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle array jenis_informasi
    String jenisInfo = '';
    if (json['jenis_informasi'] != null) {
      if (json['jenis_informasi'] is List) {
        jenisInfo = (json['jenis_informasi'] as List).join(', ');  // ✅ Join array jadi string
      } else {
        jenisInfo = json['jenis_informasi'].toString();
      }
    }

    return PpidModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nama: json['nama'] ?? '',
      divisi: json['divisi'] ?? '',
      kategoriInformasi: json['kategori_informasi'] ?? '',
      jenisInformasi: jenisInfo,  // ✅ BENAR
      filePdf: json['file_pdf'],
      fileWord: json['file_word'],
      thumbnail: json['thumnail'],  // Note: typo di backend
      status: json['status'] ?? 'menunggu',
    );
  }
}
