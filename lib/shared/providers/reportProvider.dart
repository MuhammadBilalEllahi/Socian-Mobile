// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:socian/shared/services/api_client.dart';

// final reportProvider = Provider<Report>((ref) {
//   return Report(
//     id: '',
//     name: '',
//     description: '',
//   );
// });

// class Report {
//   final String id;
//   final String name;
//   final String description;

//   Report({
//     required this.id,
//     required this.name,
//     required this.description,
//   });

//   class ReportModelType {
//     final String modelName;
//     final String id;
//     final String name;
//     final String description;

//     ReportModelType({
//       required this.id,
//       required this.modelName,
//       required this.name,
//       required this.description,
//     });
//   }

//   final apiClient = ApiClient();

//   Future<List<Report>> getReports() async {
//     final response = await apiClient.get('/api/report/types');
//     return response.data
//         .map((report) => Report(
//               id: report['_id'],
//               name: report['name'],
//               description: report['description'],
//             ))
//         .toList();
//   }

//   submitReport(String modelName, String modelId, String modelType) async {
//     final response = await apiClient.post('/api/report/submit', {
//       "$modelName": modelId,
//       "modelType": modelType,
//     });
//     return response;
//   }

//   Future<List<ReportModelType>> getReportModelTypes() async {
//     final response = await apiClient.get('/api/report/model/types');
//     return response.data
//         .map((reportModelType) => ReportModelType(
//               id: reportModelType['_id'],
//               name: reportModelType['name'],
//               description: reportModelType['description'],
//             ))
//         .toList();
//   }
// }
