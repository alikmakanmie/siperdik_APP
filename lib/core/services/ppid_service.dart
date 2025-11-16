import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/ppid_model.dart';

class PpidService {
  final String baseUrl = 'http://192.168.1.40:8000';  // ✅ Sesuaikan IP

  // GET: Fetch PPID by user_id
  Future<List<PpidModel>> getPpidByUserId(int userId) async {
    try {
      final url = '$baseUrl/api/ppid?user_id=$userId';
      print('🔍 Calling API: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        List<dynamic> ppidList = [];
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('success') && responseData['success'] == true) {
            ppidList = responseData['data'] ?? [];
          } else if (responseData.containsKey('data')) {
            ppidList = responseData['data'] ?? [];
          }
        } else if (responseData is List) {
          ppidList = responseData;
        }
        
        print('✅ Found ${ppidList.length} items');
        
        for (var item in ppidList) {
          if (item is Map<String, dynamic>) {
            print('   - ID: ${item['id']}, User ID: ${item['user_id']}, Nama: ${item['nama']}');
          }
        }
        
        return ppidList.map((item) => PpidModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

 // POST: Create PPID
Future<void> createPpid({
  required int userId,
  required String nama,
  required String divisi,
  required String kategoriInformasi,
  String? jenisInformasi,
  File? thumbnailFile,
}) async {
  try {
    var uri = Uri.parse('$baseUrl/api/ppid');
    var request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['user_id'] = userId.toString();
    request.fields['nama'] = nama;
    request.fields['divisi'] = divisi;
    request.fields['kategori_informasi'] = kategoriInformasi;
    request.fields['status'] = 'menunggu';
    
    // ✅ Kirim sebagai JSON array
    if (jenisInformasi != null) {
      request.fields['jenis_informasi'] = json.encode([jenisInformasi]);  // Wrap dalam array
    }

    // Add Thumbnail
    if (thumbnailFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnailFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      print('📎 Thumbnail added');
    }

    print('🚀 Uploading to: $uri');
    print('📦 Fields: ${request.fields}');

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print('📡 Status: ${response.statusCode}');
    print('📦 Response: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Upload successful');
    } else {
      throw Exception('Upload failed: $responseBody');
    }
  } catch (e) {
    print('❌ Error: $e');
    rethrow;
  }
}


  // PUT: Update PPID
  Future<void> updatePpid({
    required int ppidId,
    String? nama,
    String? divisi,
    String? kategoriInformasi,
    String? status,
  }) async {
    try {
      final url = '$baseUrl/api/ppid/$ppidId';
      
      Map<String, dynamic> body = {};
      if (nama != null) body['nama'] = nama;
      if (divisi != null) body['divisi'] = divisi;
      if (kategoriInformasi != null) body['kategori_informasi'] = kategoriInformasi;
      if (status != null) body['status'] = status;

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('✅ PPID updated');
      } else {
        throw Exception('Failed to update: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  // DELETE: Delete PPID
  Future<void> deletePpid(int ppidId, int userId) async {
    try {
      final url = '$baseUrl/api/ppid/$ppidId?user_id=$userId';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ PPID deleted');
      } else {
        throw Exception('Failed to delete: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}
