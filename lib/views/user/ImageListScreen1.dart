import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
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
      //print("we are here 00000000000000000000000000000000000000000000000000000000000000");
      final url = Uri.parse('${Constants.baseUrl}files/getAllImages');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': userId}), // Pass the actual user ID
      );

      if (response.contentLength! > 0) {
        setState(() {
          _images = json.decode(response.body);
          print(_images);
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
                          // Show the error image when no images are available
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
        trailing: Icon(Icons.chevron_right, color: Colors.blue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageDetailsScreen(imageId: image['_id']),
            ),
          );
        },
      ),
    );
  }
}

class ImageDetailsScreen extends StatelessWidget {
  final String imageId;

  const ImageDetailsScreen({Key? key, required this.imageId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchImageDetails() async {
    final url = Uri.parse('${Constants.baseUrl}files/getImageDetails');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': imageId}),
    );

    if (response.contentLength! > 0) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load image details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchImageDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final title = data['title'] ?? 'No Title';
            final imageUrl = '${Constants.baseUrl}upload/${data["image_name"]}';
            print(data);
            //print(imageUrl);
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ..._buildDynamicFields(data),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  List<Widget> _buildDynamicFields(Map<String, dynamic> data) {
    List<Widget> widgets = [];

    data.forEach((key, value) {
      if (['title', 'userId', 'image_name', '_id', '__v'].contains(key)) return;

      widgets.add(
        Card(
          margin: EdgeInsets.only(bottom: 12.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text(
              key,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: _buildFieldValue(value),
            trailing: Icon(Icons.wysiwyg, color: Colors.blue),
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildFieldValue(dynamic value) {
    if (value is String || value is int || value is double) {
      return Text(
        value.toString(),
        style: TextStyle(fontSize: 14),
      );
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.map((item) => Text('• $item')).toList(),
      );
    } else if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.entries.map((entry) {
          return Text('${entry.key}: ${entry.value}');
        }).toList(),
      );
    } else {
      return Text('Unsupported data type');
    }
  }
}
