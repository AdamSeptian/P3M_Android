// lib/screens/kategori/kategori_tag_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart'; // Tempat KategoriProvider & TagProvider
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class KategoriTagScreen extends StatefulWidget {
  const KategoriTagScreen({super.key});

  @override
  State<KategoriTagScreen> createState() => _KategoriTagScreenState();
}

class _KategoriTagScreenState extends State<KategoriTagScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<KategoriProvider>().fetchKategoris();
        context.read<TagProvider>().fetchTags();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Menampilkan Dialog Add / Edit
  void _showFormDialog({
    required bool isKategori,
    String? uuid,
    String? initialName,
  }) {
    final ctrl = TextEditingController(text: initialName);
    final isEdit = uuid != null;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${isEdit ? 'Edit' : 'Tambah'} ${isKategori ? 'Kategori' : 'Tag'}',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nama ${isKategori ? 'kategori' : 'tag'}...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              
              Navigator.pop(ctx); // Tutup dialog
              
              final name = ctrl.text.trim();
              if (isKategori) {
                final prov = context.read<KategoriProvider>();
                final res = isEdit 
                    ? await prov.updateKategori(uuid, name)
                    : await prov.createKategori(name);
                if (mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
              } else {
                final prov = context.read<TagProvider>();
                final res = isEdit 
                    ? await prov.updateTag(uuid, name)
                    : await prov.createTag(name);
                if (mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori & Tag'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Kategori'),
            Tab(text: 'Tag'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Cek index tab saat ini untuk menentukan mau tambah Kategori atau Tag
          final isKategori = _tabController.index == 0;
          _showFormDialog(isKategori: isKategori);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKategoriView(),
          _buildTagView(),
        ],
      ),
    );
  }

  // ─── TAB VIEW KATEGORI ─────────────────────────────────────────────────────
  Widget _buildKategoriView() {
    final prov = context.watch<KategoriProvider>();
    
    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.error != null) return ErrorState(message: prov.error!, onRetry: prov.fetchKategoris);
    if (prov.kategoris.isEmpty) {
      return EmptyState(
        message: 'Belum ada kategori',
        icon: Icons.category_outlined,
        onRefresh: prov.fetchKategoris,
      );
    }

    return RefreshIndicator(
      onRefresh: prov.fetchKategoris,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: prov.kategoris.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final k = prov.kategoris[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(Icons.label_outline, color: AppColors.primaryLight, size: 20),
              ),
              title: Text(k.namaKategori, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                    onPressed: () => _showFormDialog(isKategori: true, uuid: k.uuid, initialName: k.namaKategori),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.rejected, size: 20),
                    onPressed: () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context, title: 'Hapus Kategori', content: 'Yakin hapus kategori "${k.namaKategori}"?'
                      );
                      if (ok) {
                        final res = await context.read<KategoriProvider>().deleteKategori(k.uuid);
                        if (mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── TAB VIEW TAG ──────────────────────────────────────────────────────────
  Widget _buildTagView() {
    final prov = context.watch<TagProvider>();
    
    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.error != null) return ErrorState(message: prov.error!, onRetry: prov.fetchTags);
    if (prov.tags.isEmpty) {
      return EmptyState(
        message: 'Belum ada tag',
        icon: Icons.tag,
        onRefresh: prov.fetchTags,
      );
    }

    return RefreshIndicator(
      onRefresh: prov.fetchTags,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: prov.tags.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final t = prov.tags[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(Icons.tag, color: AppColors.accent, size: 20),
              ),
              title: Text(t.namaTag, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                    onPressed: () => _showFormDialog(isKategori: false, uuid: t.uuid, initialName: t.namaTag),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.rejected, size: 20),
                    onPressed: () async {
                      final ok = await AppHelpers.showConfirmDialog(
                        context, title: 'Hapus Tag', content: 'Yakin hapus tag "${t.namaTag}"?'
                      );
                      if (ok) {
                        final res = await context.read<TagProvider>().deleteTag(t.uuid);
                        if (mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}