import 'package:app/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:app/services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Tab index untuk BottomNavigationBar
  int _selectedIndex = 0;

  // Fungsi untuk menangani perubahan tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Widget untuk masing-masing tab
  final List<Widget> _pages = [
    // Halaman untuk tab Home
    Center(child: Text("Home Page")),
    // Halaman untuk tab Like
    Center(child: Text("Like Page")),
    // Halaman untuk tab Search
    Center(child: Text("Search Page")),
    // Halaman untuk tab Settings
    Center(child: Text("Settings Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ExampleApp'),
        backgroundColor: Color(0xFFEEEEEE), // Ganti warna yang valid
      ),
      body: _selectedIndex == 0
          ? StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List noteList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: noteList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = noteList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['note'];
                      return ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => openNoteBox(docID: docID),
                              icon: Icon(Icons.settings),
                            ),
                            IconButton(
                              onPressed: () => firestoreService.deleteNote(docID),
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No Notes"));
                }
              },
            ) : _selectedIndex == 3 ?
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    FirebaseAuth.instance.currentUser!.email!.toString(),
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      )
                    ),
                  ),
                  const SizedBox(height: 30,),
                  _logout(context)
                ],
              ),
            )
          : _pages[_selectedIndex], // Menampilkan halaman yang sesuai dengan tab yang dipilih
      bottomNavigationBar: Container(
        color: Color(0xFFFFFFFF),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            backgroundColor: Color(0xFFFFFFFF),
            color: Color(0xFF171717),
            activeColor: Color(0xFFEEEEEE),
            tabBackgroundColor: Color(0xFF171717),
            gap: 8,
            padding: EdgeInsets.all(16),
            onTabChange: _onItemTapped, // Menangani perubahan tab
            tabs: [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.favorite_border,
                text: "Like",
              ),
              GButton(
                icon: Icons.search,
                text: "Search",
              ),
              GButton(
                icon: Icons.settings,
                text: "Settings",
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  // Firestore
  final FirestoreService firestoreService = FirestoreService();

  // Text controller
  final TextEditingController textController = TextEditingController();

  // Membuka box pop up
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Enter your note"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // Menambahkan text ke firestore
                firestoreService.addNote(textController.text);
              } else {
                firestoreService.updateNote(docID, textController.text);
              }

              // Menghapus text controller
              textController.clear();

              // Menghapus jendela pop up
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Private widget
  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => openNoteBox(), // Tidak ada parameter docID
      child: Icon(Icons.add),
    );
  }

  // Private widget
  Widget _logout(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signout(context: context);
      },
      child: const Text(
        "Sign Out",
        style: TextStyle(
          color: Color(0xFFEEEEEE),
        ),
      ),
    );
  }
}
