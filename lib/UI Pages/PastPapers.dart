import 'package:flutter/material.dart';

class PastPapers extends StatelessWidget {
  final Map<String, dynamic> apiResponse;

  PastPapers({required this.apiResponse});

  @override
  Widget build(BuildContext context) {
    // Safely get the list of past papers from the API response
    final List<dynamic> pastPapers = apiResponse['pastPapers'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Past Papers'),
        backgroundColor: Colors.blueAccent,
      ),
      body: pastPapers.isEmpty
          ? Center(
        child: Text(
          'No past papers available.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: pastPapers.length,
        itemBuilder: (context, index) {
          // Safely access individual paper data
          final paper = pastPapers[index] as Map<String, dynamic>;
          final year = paper['year'] ?? 'N/A';
          final type = paper['type'] ?? 'N/A';

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListTile(
              title: Text('Year: $year'),
              subtitle: Text('Type: $type'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Define the action when a paper is tapped
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Paper Details'),
                      content: Text('Year: $year\nType: $type'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
