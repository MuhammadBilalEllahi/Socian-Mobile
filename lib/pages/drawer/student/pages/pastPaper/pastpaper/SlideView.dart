// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// class SlideView extends StatelessWidget {
//   final String id;

//   const SlideView({super.key, required this.id});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Past Papers'),
//       ),
//       body: PDFView(
//         filePath: 'path/to/your/pdf/$id.pdf',
//         enableSwipe: true,
//         swipeHorizontal: true,
//         autoSpacing: false,
//         pageFling: false,
//         onRender: (pages) {
//           print('Document rendered with $pages pages');
//         },
//         onError: (error) {
//           print(error.toString());
//         },
//         onPageError: (page, error) {
//           print('$page: ${error.toString()}');
//         },
//       ),
//     );
//   }
// }
