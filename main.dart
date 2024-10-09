import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Image Fetcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageFetcherPage(),
    );
  }
}

class ImageFetcherPage extends StatefulWidget {
  @override
  _ImageFetcherPageState createState() => _ImageFetcherPageState();
}

class _ImageFetcherPageState extends State<ImageFetcherPage> {
  List<String> imageUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    setState(() {
      isLoading = true;
    });

    final String owner = 'Ab0raya';
    final String repo = 'images';
    final String path = ''; // Empty string for root directory

    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(response.body);
      setState(() {
        imageUrls = items
            .where((item) => item['type'] == 'file' && 
                  ['png', 'jpg', 'jpeg', 'gif'].contains(item['name'].split('.').last.toLowerCase()))
            .map((item) => item['download_url'] as String)
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch images: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Image Fetcher'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imageUrls.isEmpty
              ? const Center(child: Text('No images found'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}