import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/ppid_model.dart';
import '../../../core/services/ppid_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../../division_choice/screens/division_choice_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final int userId;

  const HomeScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userId,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PpidService _ppidService = PpidService();
  List<PpidModel> _ppidData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPpidData();
  }

 Future<void> _loadPpidData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    print('🔍 Loading PPID for user_id: ${widget.userId}');
    
    final data = await _ppidService.getPpidByUserId(widget.userId);
    
    print('📦 Received ${data.length} items from API');
    for (var item in data) {
      print('   - ID: ${item.id}, User ID: ${item.userId}, Nama: ${item.nama}');
    }
    
    setState(() {
      _ppidData = data;
      _isLoading = false;
    });
  } catch (e) {
    print('❌ Error loading PPID: $e');
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0 ? _buildHomeContent() : const SettingsScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DivisionChoiceScreen(userId: widget.userId),
            ),
          );
          if (result == true) {
            _loadPpidData();
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 16),
            _buildInformationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFD4A574),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.userName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userEmail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi detail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: _loadPpidData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPpidData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else if (_ppidData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada data PPID',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          AppColors.primary.withOpacity(0.1),
        ),
        headingRowHeight: 45,
        dataRowHeight: 65,
        border: TableBorder.all(
          color: AppColors.border,
          width: 1,
        ),
        columns: const [
          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Divisi', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Jenis Info', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _ppidData.map((ppid) {
          return DataRow(
            cells: [
              DataCell(
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4A574),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${ppid.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              DataCell(Text(ppid.nama, style: const TextStyle(fontSize: 13))),
              DataCell(Text(ppid.divisi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ppid.kategoriInformasi,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataCell(Text(ppid.jenisInformasi, style: const TextStyle(fontSize: 11))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ppid.status == 'terkirim'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ppid.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ppid.status == 'terkirim' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppColors.card,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentIndex == 0 ? Icons.person : Icons.person_outline,
                      color: _currentIndex == 0
                          ? AppColors.primary
                          : AppColors.mutedForeground,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _currentIndex == 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _currentIndex == 0
                            ? AppColors.primary
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentIndex == 1 ? Icons.settings : Icons.settings_outlined,
                      color: _currentIndex == 1
                          ? AppColors.primary
                          : AppColors.mutedForeground,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _currentIndex == 1
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _currentIndex == 1
                            ? AppColors.primary
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}  // ✅ Closing bracket yang hilang
