import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PastPapers extends StatefulWidget {
  @override
  _PastPapersState createState() => _PastPapersState();
}

class _PastPapersState extends State<PastPapers> {
  late Future<List<dynamic>> pastPapers;

  @override
  void initState() {
    super.initState();
    pastPapers = fetchPastPapers();
  }

  Future<List<dynamic>> fetchPastPapers() async {
    const String url = "http://192.168.10.6:8080/api/pastpaper/all-pastpapers-in-subject/67818286a465ca0130eafafd";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-platform': 'app', // Add the x-platform header
          // 'Content-Type': 'application/json', // Optional, if needed by the backend
        },
      );
      if (response.statusCode == 200) {
        debugPrint("200 response");
        final data = json.decode(response.body);
        return data['pastPapers'] ?? [];
      } else {
        debugPrint("error response");

        throw Exception('Failed to load past papers exception');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Papers'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: pastPapers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No past papers available.'),
            );
          } else {
            final papers = snapshot.data!;
            return ListView.builder(
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final paper = papers[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Year: ${paper['year']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        if ((paper['assignments'] as List).isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (paper['assignments'] as List).map((assignment) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Assignment: ${assignment['name']}'),
                                  Text('PDF Link: ${assignment['file']['pdf']}'),
                                  SizedBox(height: 4),
                                ],
                              );
                            }).toList(),
                          )
                        else
                          Text('No assignments available'),
                        Divider(),
                        if ((paper['fall']['final']['theory'] as List).isNotEmpty)
                          Text('Fall Final Theory Papers:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (paper['fall']['final']['theory'] as List).map((theory) {
                            return Text('• ${theory['name']} (PDF: ${theory['file']['pdf']})');
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
