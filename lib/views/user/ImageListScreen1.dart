import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scan_app/services/user_service.dart';
import 'package:scan_app/utils/constants.dart';
import 'package:scan_app/utils/permissions_helper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ImageListScreen1 extends StatefulWidget {
  const ImageListScreen1({Key? key}) : super(key: key);

  @override
  _ImageListScreen1State createState() => _ImageListScreen1State();
}

class _ImageListScreen1State extends State<ImageListScreen1> {
  List<dynamic> _images = [];
  List<String> _selectedImageIds = []; // IDs des images sélectionnées
  bool _isLoading = true;
  String userId = "";
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndImages();
  }

  Future<void> _fetchUserIdAndImages() async {
    try {
      final id = await _fetchUserId();
      if (id.isNotEmpty) {
        setState(() {
          userId = id;
        });
        await _fetchImages();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found. Please log in.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<void> _fetchImages() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}files/getAllImages');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': userId}),
      );

      if (response.contentLength! > 0) {
        setState(() {
          _images = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch images.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _toggleSelection(String imageId) {
    setState(() {
      if (_selectedImageIds.contains(imageId)) {
        _selectedImageIds.remove(imageId);
      } else {
        _selectedImageIds.add(imageId);
      }
    });
  }

  Future<void> _deleteSelectedImages() async {
    if (_selectedImageIds.isEmpty) return;

    try {
      final url = Uri.parse('${Constants.baseUrl}files/deleteImages');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _selectedImageIds}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _images.removeWhere((image) => _selectedImageIds.contains(image['userId']));
          _selectedImageIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected images deleted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete selected images.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  
  Future<String?> downloadPDF(String userId) async {
    // Request permission before accessing storage

    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        print('Permission denied. Cannot download file.');
        return null;
      }
      final response = await userService.generatePDFFromOCRData(userId);

      if (response.statusCode == 200) {
        final customDirectoryPath =
            '/storage/emulated/0/Download/ScanApp'; // Android Download folder
        final downloadDirectory = Directory('$customDirectoryPath'); // Custom folder within Downloads

        // Ensure the directory exists
        //final directory = Directory(customDirectoryPath);
        print("____________________________1");

        if (!(await downloadDirectory.exists())) {
          print("____________________________1.5");

          await downloadDirectory.create(recursive: true);//the error is here after print trace
        }
        print("____________________________2");

        // final filePath = '$customDirectoryPath/generated_pdf_$userId.pdf';
        final filePath = '${downloadDirectory.path}/generated_pdf_$userId.pdf';

        // Save the PDF to the custom path
        final file = File(filePath);
        print("____________________________1");

        await file.writeAsBytes(response.bodyBytes);
        print("____________________________12");

        print('PDF saved at $filePath');
        print('File downloaded to: $filePath');
        return filePath;
      } else {
        print('Failed to download PDF: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedImageIds.isEmpty
                ? null
                : _deleteSelectedImages, // Bouton pour supprimer les images sélectionnées
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              downloadPDF(
                  userId); // Call your download function when the button is pressed
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: Text(
                      'Manage your documents easily',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: _images.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/imagelistnotfound-removebg-preview.png',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'No images available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            final image = _images[index];
                            return _buildImageItem(image);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageItem(dynamic image) {
    final isSelected = _selectedImageIds.contains(image['_id']);

    return Card(
      margin: EdgeInsets.only(bottom: 12.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Image.network(
          '${Constants.baseUrl}upload/${image["image_name"]}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          image['title'] ?? 'No Title',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) => _toggleSelection(image['_id']),
        ),
        onTap: () {
          _toggleSelection(image['_id']);
        },
      ),
    );
  }
}
