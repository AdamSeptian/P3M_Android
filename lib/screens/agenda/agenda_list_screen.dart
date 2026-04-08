// lib/screens/agenda/agenda_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agenda_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import 'agenda_form_screen.dart';

class AgendaListScreen extends StatefulWidget {
  const AgendaListScreen({super.key});
  @override
  State<AgendaListScreen> createState() => _AgendaListScreenState();
}

class _AgendaListScreenState extends State<AgendaListScreen> {
  String _filter = 'all';
  String _search = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<AgendaProvider>().fetchAgendas();
    }
  }

  List<AgendaModel> _filtered(List<AgendaModel> all) {
    return all.where((a) {
      final matchStatus = _filter == 'all' || a.status == _filter;
      final matchSearch = _search.isEmpty ||
          a.namaKegiatan.toLowerCase().contains(_search.toLowerCase()) ||
          a.tuanRumah.toLowerCase().contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AgendaProvider>();
    final auth = context.watch<AuthProvider>();
    final filtered = _filtered(prov.agendas);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Agenda'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: prov.fetchAgendas),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AgendaFormScreen()),
        ).then((_) => prov.fetchAgendas()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Agenda',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          AppSearchBar(
            hint: 'Cari nama kegiatan atau tuan rumah...',
            onChanged: (v) => setState(() => _search = v),
          ),
          StatusFilterChips(
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : prov.error != null
                    ? ErrorState(message: prov.error!, onRetry: prov.fetchAgendas)
                    : filtered.isEmpty
                        ? EmptyState(
                            message: 'Tidak ada agenda ditemukan',
                            icon: Icons.event_outlined,
                            onRefresh: prov.fetchAgendas,
                          )
                        : RefreshIndicator(
                            onRefresh: prov.fetchAgendas,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, i) => _AgendaCard(
                                agenda: filtered[i],
                                isAdmin: auth.isAdmin,
                                onRefresh: prov.fetchAgendas,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final AgendaModel agenda;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const _AgendaCard({required this.agenda, required this.isAdmin, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AgendaProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_rounded, color: AppColors.cardGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agenda.namaKegiatan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(agenda.tuanRumah,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                AppHelpers.statusChip(agenda.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text('Jadwal: ${AppHelpers.formatDate(agenda.jadwal)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                const Icon(Icons.picture_as_pdf_outlined, size: 13, color: AppColors.rejected),
                const SizedBox(width: 4),
                const Text('PDF tersedia',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.rejected,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            if (agenda.username != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text('@${agenda.username}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            VerificationActionRow(
              status: agenda.status,
              isAdmin: isAdmin,
              onVerify: isAdmin ? () async {
                final ok = await AppHelpers.showConfirmDialog(context,
                  title: 'Verifikasi Agenda',
                  content: 'Verifikasi agenda "${agenda.namaKegiatan}"?',
                  confirmText: 'Verifikasi',
                  confirmColor: AppColors.verified,
                );
                if (ok) {
                  final res = await prov.verifyAgenda(agenda.uuid);
                  if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                }
              } : null,
              onReject: isAdmin ? () async {
                final ok = await AppHelpers.showConfirmDialog(context,
                  title: 'Tolak Agenda',
                  content: 'Tolak agenda "${agenda.namaKegiatan}"?',
                  confirmText: 'Tolak',
                  confirmColor: AppColors.rejected,
                );
                if (ok) {
                  final res = await prov.rejectAgenda(agenda.uuid);
                  if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                }
              } : null,
              onCancelVerify: isAdmin ? () async {
                final ok = await AppHelpers.showConfirmDialog(context,
                  title: 'Batalkan Verifikasi',
                  content: 'Status akan kembali ke Pending.',
                );
                if (ok) {
                  final res = await prov.cancelVerifyAgenda(agenda.uuid);
                  if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                }
              } : null,
              onCancelReject: isAdmin ? () async {
                final ok = await AppHelpers.showConfirmDialog(context,
                  title: 'Pulihkan Agenda',
                  content: 'Status akan kembali ke Pending.',
                );
                if (ok) {
                  final res = await prov.cancelRejectAgenda(agenda.uuid);
                  if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                }
              } : null,
              onEdit: agenda.status != 'verified' ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AgendaFormScreen(agenda: agenda)),
              ).then((_) => onRefresh()) : null,
              onDelete: () async {
                final ok = await AppHelpers.showConfirmDialog(context,
                  title: 'Hapus Agenda',
                  content: 'Agenda akan dihapus permanen.',
                  confirmText: 'Hapus',
                  confirmColor: AppColors.rejected,
                );
                if (ok) {
                  final res = await prov.deleteAgenda(agenda.uuid);
                  if (context.mounted) AppHelpers.showSnackBar(context, res.message, isError: res.isError);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}