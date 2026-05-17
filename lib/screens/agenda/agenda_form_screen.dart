// lib/screens/agenda/agenda_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart'; // Menggunakan model yang sudah disatukan
import '../../providers/agenda_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class AgendaFormScreen extends StatefulWidget {
  final AgendaModel? agenda;
  const AgendaFormScreen({super.key, this.agenda});

  @override
  State<AgendaFormScreen> createState() => _AgendaFormScreenState();
}

class _AgendaFormScreenState extends State<AgendaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _tuanRumahCtrl = TextEditingController();
  DateTime? _selectedDate;
  File? _pdfFile;
  String? _pdfFileName;
  bool _isSubmitting = false;

  bool get isEdit => widget.agenda != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaCtrl.text = widget.agenda!.namaKegiatan;
      _tuanRumahCtrl.text = widget.agenda!.tuanRumah;
      if (widget.agenda!.jadwal.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(widget.agenda!.jadwal);
        } catch (_) {
          // Abaikan jika format tanggal tidak valid
        }
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _tuanRumahCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      AppHelpers.showSnackBar(context, 'Pilih jadwal terlebih dahulu', isError: true);
      return;
    }
    
    if (!isEdit && _pdfFile == null) {
      AppHelpers.showSnackBar(context, 'Upload file PDF terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    
    final prov = context.read<AgendaProvider>();
    final jadwal = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    ApiResponse res;
    if (isEdit) {
      res = await prov.updateAgenda(
        uuid: widget.agenda!.uuid,
        namaKegiatan: _namaCtrl.text.trim(),
        tuanRumah: _tuanRumahCtrl.text.trim(),
        jadwal: jadwal,
        pdfFile: _pdfFile, // Bisa null jika tidak ada file baru yang diunggah
      );
    } else {
      res = await prov.createAgenda(
        namaKegiatan: _namaCtrl.text.trim(),
        tuanRumah: _tuanRumahCtrl.text.trim(),
        jadwal: jadwal,
        pdfFile: _pdfFile!, // Wajib ada untuk create
      );
    }

    setState(() => _isSubmitting = false);
    
    if (mounted) {
      AppHelpers.showSnackBar(context, res.message, isError: res.isError);
      if (res.isSuccess) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Agenda' : 'Tambah Agenda')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Nama Kegiatan'),
                  TextFormField(
                    controller: _namaCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nama kegiatan/acara',
                      prefixIcon: Icon(Icons.event_outlined, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama kegiatan wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Tuan Rumah'),
                  TextFormField(
                    controller: _tuanRumahCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Instansi/individu tuan rumah',
                      prefixIcon: Icon(Icons.business_outlined, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Tuan rumah wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Jadwal'),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 20, color: AppColors.textHint),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? AppHelpers.formatDate(_selectedDate!.toIso8601String())
                                : 'Pilih tanggal',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: _selectedDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textHint),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _label('File PDF'),
                  GestureDetector(
                    onTap: _pickPdf,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _pdfFile != null ? AppColors.verified : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.rejected.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.picture_as_pdf_outlined,
                                color: AppColors.rejected, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pdfFile != null
                                      ? (_pdfFileName ?? 'File dipilih')
                                      : isEdit
                                          ? 'PDF saat ini: ${widget.agenda!.file}'
                                          : 'Tap untuk pilih file PDF',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _pdfFile != null ? 'File siap diupload' : 'Format: PDF. Maks 5MB',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: _pdfFile != null
                                        ? AppColors.verified
                                        : AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _pdfFile != null ? Icons.check_circle : Icons.upload_file,
                            color: _pdfFile != null ? AppColors.verified : AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Buat Agenda',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      );
}