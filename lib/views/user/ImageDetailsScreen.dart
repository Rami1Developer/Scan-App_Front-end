import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scan_app/utils/constants.dart';
import 'package:http/http.dart' as http;

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