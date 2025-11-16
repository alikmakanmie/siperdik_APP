// lib/core/services/ppid_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PpidService {
  final String baseUrl = 'http://192.168.1.40:8000/api';

  Future<Map<String, dynamic>> createPpid({
    required int userId,
    required String nama,
    required String divisi,
    required String kategoriInformasi,
    String? jenisInformasi,
    File? thumbnailFile,
    File? pdfFile,       // ✅ Parameter PDF
    File? wordFile,      // ✅ Parameter Word
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/ppid');
      final request = http.MultipartRequest('POST', uri);

      // ✅ Add text fields
      request.fields['user_id'] = userId.toString();
      request.fields['nama'] = nama;
      request.fields['divisi'] = divisi;
      request.fields['kategori_informasi'] = kategoriInformasi;
      
      if (jenisInformasi != null) {
        request.fields['jenis_informasi'] = jenisInformasi;
      }

      // ✅ Add PDF file
      if (pdfFile != null) {
        print('📄 Uploading PDF: ${pdfFile.path}');
        request.files.add(await http.MultipartFile.fromPath(
          'file_pdf',  // ✅ MUST match Laravel field name
          pdfFile.path,
        ));
      }

      // ✅ Add Word file
      if (wordFile != null) {
        print('📝 Uploading Word: ${wordFile.path}');
        request.files.add(await http.MultipartFile.fromPath(
          'file_word',  // ✅ MUST match Laravel field name
          wordFile.path,
        ));
      }

      // ✅ Add Thumbnail
      if (thumbnailFile != null) {
        print('🖼️ Uploading Thumbnail: ${thumbnailFile.path}');
        request.files.add(await http.MultipartFile.fromPath(
          'thumnail',  // ✅ Typo di database Anda: 'thumnail' bukan 'thumbnail'
          thumbnailFile.path,
        ));
      }

      print('🚀 Sending request to: $uri');
      print('📦 Fields: ${request.fields}');
      print('📁 Files: ${request.files.length} files');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create PPID: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in createPpid: $e');
      rethrow;
    }
  }

  // ✅ Get PPID list
  Future<List<dynamic>> getPpidByUser(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/ppid?user_id=$userId');
      print('🔍 Loading PPID for user_id: $userId');
      print('🔍 Calling API: $uri');

      final response = await http.get(uri);
      
      print('📡 Status: ${response.statusCode}');
      print('📡 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] as List;
        
        print('✅ Found ${items.length} items');
        for (var item in items) {
          print('   - ID: ${item['id']}, User ID: ${item['user_id']}, Nama: ${item['nama']}');
        }
        
        return items;
      } else {
        throw Exception('Failed to load PPID');
      }
    } catch (e) {
      print('❌ Error loading PPID: $e');
      rethrow;
    }
  }
}
