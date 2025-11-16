import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';

class HpphInputScreen extends StatefulWidget {
  const HpphInputScreen({Key? key}) : super(key: key);

  @override
  State<HpphInputScreen> createState() => _HpphInputScreenState();
}

class _HpphInputScreenState extends State<HpphInputScreen> {
  int _selectedCategory = 0; // Default: INFORMASI BERKALA
  int? _selectedRingkasan; // Tidak ada yang dipilih di awal
  
  File? _thumbnailFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // List ringkasan isi informasi
  final List<String> _ringkasanOptions = [
    'Informasi yang Berkaitan dengan Profil Bawaslu',
    'Informasi Program dan Kinerja Bawaslu',
    'Informasi Mengenai Keuangan',
    'Informasi Mengenai Organisasi, Administrasi dan Kepegawaian',
    'Informasi Mengenai Pelayanan Informasi Publik',
    'Informasi hasil Penelitian',
  ];

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          _thumbnailFile = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thumbnail berhasil dipilih'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilePickerDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih $type'),
        content: Text('Fitur upload $type akan diimplementasikan'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearFile(String type) {
    setState(() {
      if (type == 'thumbnail') _thumbnailFile = null;
    });
  }

  Future<void> _handleSubmit() async {
    // Validasi
    if (_selectedRingkasan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih ringkasan isi informasi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data HPPH berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _isUploading = false;
      });
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HPPH',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Daftar Informasi Publik
            Row(
              children: [
                const Text(
                  'Daftar Informasi Publik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Category Buttons
            _buildCategoryButton(
              'Informasi Berkala',
              isSelected: _selectedCategory == 0,
              onTap: () => setState(() => _selectedCategory = 0),
            ),
            const SizedBox(height: 12),
            
            _buildCategoryButton(
              'Informasi Tersedia Setiap Saat',
              isSelected: _selectedCategory == 1,
              onTap: () => setState(() => _selectedCategory = 1),
            ),
            const SizedBox(height: 12),
            
            _buildCategoryButton(
              'Informasi Serta Merta',
              isSelected: _selectedCategory == 2,
              onTap: () => setState(() => _selectedCategory = 2),
            ),
            const SizedBox(height: 32),
            
            // Section 2: Ringkasan Isi Informasi
            Row(
              children: [
                const Text(
                  'Ringkasan Isi Informasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Ringkasan Options
            ...List.generate(_ringkasanOptions.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRingkasanButton(
                  _ringkasanOptions[index],
                  isSelected: _selectedRingkasan == index,
                  onTap: () => setState(() => _selectedRingkasan = index),
                ),
              );
            }),
            
            const SizedBox(height: 32),
            
            // Upload Section Title
            Row(
              children: [
                const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color(0xFFD4A574),
                ),
                const SizedBox(width: 8),
                const Text(
                  'upload file!!!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // PDF Upload
            _buildFileUploadCard(
              label: 'upload file pdf.',
              iconPath: 'PDF',
              iconColor: Colors.red,
              onTap: () => _showFilePickerDialog('PDF'),
            ),
            const SizedBox(height: 12),
            
            // Word Upload
            _buildFileUploadCard(
              label: 'upload file word.',
              iconPath: 'W',
              iconColor: Colors.blue,
              onTap: () => _showFilePickerDialog('Word'),
            ),
            const SizedBox(height: 12),
            
            // Thumbnail Upload
            _buildFileUploadCard(
              label: 'upload file thumbnail.',
              iconPath: '🖼️',
              iconColor: Colors.grey,
              onTap: _pickThumbnail,
              file: _thumbnailFile,
              onClear: () => _clearFile('thumbnail'),
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A574),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isUploading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Transform.rotate(
                            angle: -0.785398,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _handleSubmit,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    String text, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9800) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF757575),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRingkasanButton(
    String text, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF757575),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFileUploadCard({
    required String label,
    required String iconPath,
    required Color iconColor,
    required VoidCallback onTap,
    File? file,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            if (file != null && onClear != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconPath == 'PDF' || iconPath == 'W')
                      Text(
                        iconPath,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      )
                    else
                      Text(
                        iconPath,
                        style: const TextStyle(fontSize: 18),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
