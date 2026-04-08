// lib/screens/berita/berita_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/berita_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import '../../services/api_service.dart';

class BeritaFormScreen extends StatefulWidget {
  final BeritaModel? berita;
  const BeritaFormScreen({super.key, this.berita});
  @override
  State<BeritaFormScreen> createState() => _BeritaFormScreenState();
}

class _BeritaFormScreenState extends State<BeritaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false;
  Set<String> _selectedKategori = {};
  Set<String> _selectedTag = {};

  bool get isEdit => widget.berita != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _judulCtrl.text = widget.berita!.judulBerita;
      _isiCtrl.text = widget.berita!.isiBerita;
      _selectedKategori = widget.berita!.kategoris.map((k) => k.uuid).toSet();
      _selectedTag = widget.berita!.tags.map((t) => t.uuid).toSet();
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isEdit && _imageFile == null) {
      AppHelpers.showSnackBar(context, 'Pilih gambar terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final prov = context.read<BeritaProvider>();
    ApiResponse res;

    if (isEdit) {
      res = await prov.updateBerita(
        uuid: widget.berita!.uuid,
        judul: _judulCtrl.text.trim(),
        isi: _isiCtrl.text.trim(),
        imageFile: _imageFile,
        kategoriUuids: _selectedKategori.toList(),
        tagUuids: _selectedTag.toList(),
      );
    } else {
      res = await prov.createBerita(
        judul: _judulCtrl.text.trim(),
        isi: _isiCtrl.text.trim(),
        imageFile: _imageFile!,
        kategoriUuids: _selectedKategori.toList(),
        tagUuids: _selectedTag.toList(),
      );
    }

    setState(() => _isSubmitting = false);
    if (mounted) {
      AppHelpers.showSnackBar(context, res.message, isError: res.isError);
      if (res.isSuccess) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kategoris = context.watch<KategoriProvider>().kategoris;
    final tags = context.watch<TagProvider>().tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Berita' : 'Tambah Berita'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker
                  _buildLabel('Gambar Berita'),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : isEdit && widget.berita!.url.isNotEmpty
                              ? Stack(
                                  children: [
                                    AppNetworkImage(
                                      url: widget.berita!.url,
                                      width: double.infinity,
                                      height: 160,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit, color: Colors.white, size: 32),
                                            Text('Tap untuk ganti gambar',
                                              style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                      size: 40, color: AppColors.textHint),
                                    SizedBox(height: 8),
                                    Text('Tap untuk pilih gambar',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text('Format: JPG, PNG. Maks 5MB',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  _buildLabel('Judul Berita'),
                  TextFormField(
                    controller: _judulCtrl,
                    maxLength: 200,
                    decoration: const InputDecoration(hintText: 'Masukkan judul berita'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Isi
                  _buildLabel('Isi Berita'),
                  TextFormField(
                    controller: _isiCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Tulis isi berita di sini...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi berita wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Kategori
                  _buildLabel('Kategori'),
                  if (kategoris.isEmpty)
                    const Text('Belum ada kategori',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12, fontFamily: 'Poppins'))
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: kategoris.map((k) {
                        final selected = _selectedKategori.contains(k.uuid);
                        return FilterChip(
                          label: Text(k.namaKategori,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            if (v) _selectedKategori.add(k.uuid);
                            else _selectedKategori.remove(k.uuid);
                          }),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // Tag
                  _buildLabel('Tag'),
                  if (tags.isEmpty)
                    const Text('Belum ada tag',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12, fontFamily: 'Poppins'))
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((t) {
                        final selected = _selectedTag.contains(t.uuid);
                        return FilterChip(
                          label: Text(t.namaTag,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            if (v) _selectedTag.add(t.uuid);
                            else _selectedTag.remove(t.uuid);
                          }),
                          selectedColor: AppColors.accentLight.withOpacity(0.8),
                          backgroundColor: AppColors.surface,
                          checkmarkColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selected ? AppColors.accent : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Kirim Berita',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isSubmitting) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
    ),
  );
}