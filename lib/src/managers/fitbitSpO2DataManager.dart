import 'package:logger/logger.dart';

import 'package:fitbitter/src/urls/fitbitAPIURL.dart';

import 'package:fitbitter/src/data/fitbitData.dart';
import 'package:fitbitter/src/data/fitbitSpO2Data.dart';

import 'package:fitbitter/src/managers/fitbitDataManager.dart';

/// [FitbitSpO2DataManager] is a class the manages the requests related to
/// [FitbitSpO2Data].
class FitbitSpO2DataManager extends FitbitDataManager {
  FitbitSpO2DataManager(
      {required String clientID, required String clientSecret})
      : super(
          clientID: clientID,
          clientSecret: clientSecret,
        );

  @override
  Future<List<FitbitData>> fetch(FitbitAPIURL fitbitUrl) async {
    // Get the response
    final response = await getResponse(fitbitUrl);

    // Debugging
    final logger = Logger();
    logger.i('$response');

    //Extract data and return them
    List<FitbitData> ret =
        _extractFitbitSpO2Data(response, fitbitUrl.fitbitCredentials!.userID);
    return ret;
  } // fetch

  /// A private method that extracts [FitbitSpO2Data] from the given response.
  List<FitbitSpO2Data> _extractFitbitSpO2Data(
      dynamic response, String? userId) {
    final data = response;
    List<FitbitSpO2Data> spO2DataPoints =
        List<FitbitSpO2Data>.empty(growable: true);

    if (data.isNotEmpty) {
      if (data is Iterable<dynamic>) {
        for (var record in data) {
          print(record);
          print(FitbitSpO2Data.fromJson(json: record));
          print(DateTime.parse(record['dateTime']));
          spO2DataPoints.add(FitbitSpO2Data(
            userID: userId,
            dateOfMonitoring: DateTime.parse(record['dateTime']),
            avgValue: _safeParseDouble(record['value']['avg']),
            minValue: _safeParseDouble(record['value']['min']),
            maxValue: _safeParseDouble(record['value']['max']),
          ));
        } // for entry
      } else {
        spO2DataPoints.add(FitbitSpO2Data(
          userID: userId,
          dateOfMonitoring: DateTime.parse(data['dateTime']),
          avgValue: _safeParseDouble(data['value']['avg']),
          minValue: _safeParseDouble(data['value']['min']),
          maxValue: _safeParseDouble(data['value']['max']),
        ));
      }
    }
    return spO2DataPoints;
  } // _extractFitbitSpO2Data

  // Helper method to safely parse values that might be strings, numbers, or ranges
double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value.contains('-')) {
      // Handle range values like "47-51"
      final parts = value.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].trim());
        final max = double.tryParse(parts[1].trim());
        if (min != null && max != null) {
          return (min + max) / 2; // Return the average of the range
        }
      }
    }
    // Try to parse as a regular double
    return double.tryParse(value);
  }
  return null;
}
} // FitbitSpO2DataManager
