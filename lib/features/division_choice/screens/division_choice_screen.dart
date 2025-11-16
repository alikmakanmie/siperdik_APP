import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';  // ✅ TAMBAH
import '../../../core/constants/app_colors.dart';
import '../../../core/services/ppid_service.dart';

class DivisionChoiceScreen extends StatefulWidget {
  final int userId;

  const DivisionChoiceScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<DivisionChoiceScreen> createState() => _DivisionChoiceScreenState();
}

class _DivisionChoiceScreenState extends State<DivisionChoiceScreen> {
  int? _selectedDivision;
  int _selectedCategory = 0;
  int? _selectedRingkasan;
  final PpidService _ppidService = PpidService();

  File? _thumbnailFile;
  File? _pdfFile;      // ✅ TAMBAH
  File? _wordFile;     // ✅ TAMBAH
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _divisionList = ['HPPH', 'PPPS', 'SDMO-D'];
  final List<String> _categoryList = [
    'Informasi Berkala',
    'Informasi Tersedia Setiap Saat',
    'Informasi Serta Merta',
  ];

  final List<String> _ringkasanBerkala = [
    'Informasi yang Berkaitan dengan Profil Bawaslu',
    'Informasi Program dan Kinerja Bawaslu',
    'Informasi Mengenai Keuangan',
    'Informasi Mengenai Organisasi, Administrasi dan Kepegawaian',
    'Informasi Mengenai Pelayanan Informasi Publik',
    'Informasi hasil Penelitian',
  ];

  final List<String> _ringkasanTersedia = [
    'Informasi Mengenai Peraturan Keputusan dan/atau Kebijakan',
  ];

  List<String> get _currentRingkasanOptions {
    if (_selectedCategory == 0) {
      return _ringkasanBerkala;
    } else if (_selectedCategory == 1) {
      return _ringkasanTersedia;
    }
    return [];
  }

  // ✅ TAMBAH: Pick PDF file
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() => _pdfFile = File(result.files.single.path!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF file berhasil dipilih'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ TAMBAH: Pick Word file
  Future<void> _pickWordFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx'],
      );

      if (result != null) {
        setState(() => _wordFile = File(result.files.single.path!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Word file berhasil dipilih'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih Word: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _thumbnailFile = File(image.path));
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

  Future<void> _handleSubmit() async {
    if (_selectedDivision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih divisi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if ((_selectedCategory == 0 || _selectedCategory == 1) && 
        _selectedRingkasan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih ringkasan isi informasi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String kategoriValue = '';
      if (_selectedCategory == 0) {
        kategoriValue = 'informasi_berkala';
      } else if (_selectedCategory == 1) {
        kategoriValue = 'informasi_tersedia_setiap_saat';
      } else if (_selectedCategory == 2) {
        kategoriValue = 'informasi_serta_merta';
      }

      String? jenisInformasi;
      if (_selectedRingkasan != null) {
        if (_selectedCategory == 0) {
          jenisInformasi = _ringkasanBerkala[_selectedRingkasan!];
        } else if (_selectedCategory == 1) {
          jenisInformasi = _ringkasanTersedia[_selectedRingkasan!];
        }
      }

      print('🚀 Sending: User ${widget.userId}, Divisi ${_divisionList[_selectedDivision!]}');

      // ✅ Kirim dengan PDF & Word
      await _ppidService.createPpid(
        userId: widget.userId,
        nama: 'Data PPID ${_divisionList[_selectedDivision!]}',
        divisi: _divisionList[_selectedDivision!],
        kategoriInformasi: kategoriValue,
        jenisInformasi: jenisInformasi,
        thumbnailFile: _thumbnailFile,
        pdfFile: _pdfFile,      // ✅ TAMBAH
        wordFile: _wordFile,    // ✅ TAMBAH
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data ${_divisionList[_selectedDivision!]} berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isUploading = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isUploading = false);
      }
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
          'Input Data',
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
            Row(
              children: const [
                Text(
                  'Pilih Divisi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                Text('*', style: TextStyle(fontSize: 16, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            
            ...List.generate(_divisionList.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedDivision = index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedDivision == index
                            ? const Color(0xFFFF9800)
                            : const Color(0xFFE0E0E0),
                        width: _selectedDivision == index ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selectedDivision == index,
                          onChanged: (value) => setState(() => _selectedDivision = index),
                          activeColor: const Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _divisionList[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedDivision == index
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _selectedDivision == index
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 32),
            
            Row(
              children: const [
                Text(
                  'Daftar Informasi Publik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                Text('*', style: TextStyle(fontSize: 16, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            
            ...List.generate(_categoryList.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryButton(
                  _categoryList[index],
                  isSelected: _selectedCategory == index,
                  onTap: () {
                    setState(() {
                      _selectedCategory = index;
                      _selectedRingkasan = null;
                    });
                  },
                ),
              );
            }),
            
            if (_selectedCategory == 0 || _selectedCategory == 1) ...[
              const SizedBox(height: 32),
              
              Row(
                children: const [
                  Text(
                    'Ringkasan Isi Informasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  Text('*', style: TextStyle(fontSize: 16, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              
              ...List.generate(_currentRingkasanOptions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRingkasanButton(
                    _currentRingkasanOptions[index],
                    isSelected: _selectedRingkasan == index,
                    onTap: () => setState(() => _selectedRingkasan = index),
                  ),
                );
              }),
            ],
            
            const SizedBox(height: 32),
            
            Row(
              children: const [
                Icon(Icons.edit, size: 20, color: Color(0xFFD4A574)),
                SizedBox(width: 8),
                Text(
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
            
            // ✅ UPDATE: File upload section
            _buildFileUploadCard(
              label: 'upload file pdf.',
              iconPath: 'PDF',
              iconColor: Colors.red,
              onTap: _pickPdfFile,  // ✅ GANTI
              file: _pdfFile,
              onClear: () => setState(() => _pdfFile = null),
            ),
            const SizedBox(height: 12),
            
            _buildFileUploadCard(
              label: 'upload file word.',
              iconPath: 'W',
              iconColor: Colors.blue,
              onTap: _pickWordFile,  // ✅ GANTI
              file: _wordFile,
              onClear: () => setState(() => _wordFile = null),
            ),
            const SizedBox(height: 12),
            
            _buildFileUploadCard(
              label: 'upload file thumbnail.',
              iconPath: '🖼️',
              iconColor: Colors.grey,
              onTap: _pickThumbnail,
              file: _thumbnailFile,
              onClear: () => setState(() => _thumbnailFile = null),
            ),
            const SizedBox(height: 32),
            
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
                            child: const Icon(Icons.send, color: Colors.white),
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

  Widget _buildCategoryButton(String text, {required bool isSelected, required VoidCallback onTap}) {
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

  Widget _buildRingkasanButton(String text, {required bool isSelected, required VoidCallback onTap}) {
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
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                file != null ? file.path.split('/').last : label,  // ✅ SHOW FILENAME
                style: TextStyle(
                  fontSize: 14,
                  color: file != null ? AppColors.foreground : const Color(0xFF9E9E9E),
                  fontWeight: file != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
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
                child: Text(
                  iconPath,
                  style: TextStyle(
                    fontSize: iconPath == 'PDF' || iconPath == 'W' ? 14 : 18,
                    fontWeight: iconPath == 'PDF' || iconPath == 'W' ? FontWeight.bold : FontWeight.normal,
                    color: iconPath == 'PDF' || iconPath == 'W' ? iconColor : Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
