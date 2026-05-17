// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'berita/berita_list_screen.dart';
import 'agenda/agenda_list_screen.dart';

// Pastikan file-file di bawah ini sudah kamu buat
import 'users/users_list_screen.dart';
import 'kategori/kategori_tag_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pantau status otentikasi dan role
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    // Daftar layar yang akan dirender ke dalam IndexedStack
    final screens = [
      const DashboardScreen(),
      const BeritaListScreen(),
      const AgendaListScreen(),
      if (isAdmin) const UsersListScreen(),
      if (isAdmin) const KategoriTagScreen(),
    ];

    // Daftar item navigasi di bagian bawah
    final navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.newspaper_outlined),
        activeIcon: Icon(Icons.newspaper_rounded),
        label: 'Berita',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.event_outlined),
        activeIcon: Icon(Icons.event_rounded),
        label: 'Agenda',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people_rounded),
          label: 'Pengguna',
        ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.label_outline),
          activeIcon: Icon(Icons.label_rounded),
          label: 'Kategori',
        ),
    ];

    // Mencegah error index out of bounds jika role berubah saat runtime
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          backgroundColor: AppColors.surface,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
          ),
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}