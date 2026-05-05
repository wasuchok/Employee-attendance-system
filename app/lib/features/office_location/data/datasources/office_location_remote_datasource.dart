import 'package:app/core/constants/api_constants.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/office_location/domain/models/office_location.dart';

class OfficeLocationRemoteDatasource {
  final ApiClient apiClient;

  OfficeLocationRemoteDatasource({required this.apiClient});

  Future<List<OfficeLocation>> getOfficeLocations() async {
    final response = await apiClient.get(ApiConstants.officeLocationLists);

    final data = response.data;
    final locationsData = data is Map ? data['data'] : null;

    if (locationsData is! List) {
      return [];
    }

    return locationsData
        .whereType<Map>()
        .map((json) => OfficeLocation.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
