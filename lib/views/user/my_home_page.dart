import 'package:flutter/material.dart';
import 'package:scan_app/views/ProfileScreen.dart';
import 'package:scan_app/views/user/ImageListScreen1.dart';
import 'package:scan_app/views/user/UploadAndAnalyzeScreen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ImageListScreen1(),
    UploadAndAnalyzeScreen(), // Passe directement updateIndex
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Afficher la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
        
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload Image',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}