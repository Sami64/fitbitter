import 'package:fitbitter/src/data/fitbitData.dart';

/// [FitbitCardioScoreData] is a class implementing the data model of the
/// cardio score data.
class FitbitCardioScoreData implements FitbitData {
  /// The user encoded id.
  String? userID;

  /// The date of monitoring of the data.
  DateTime? dateOfMonitoring;

  /// The value of the data (will be the average if it's a range).
  double? value;

  /// The original VO2 Max string as returned by the API
  String? rawValue;


  /// Default [FitbitCardioScoreData] constructor.
  FitbitCardioScoreData({
    this.userID,
    this.dateOfMonitoring,
    this.value,
    this.rawValue,
  });

  // Helper method to parse VO2 Max values that might be ranges
  static double? parseVo2Max(dynamic vo2Max) {
    if (vo2Max == null) return null;
    if (vo2Max is num) return vo2Max.toDouble();
    if (vo2Max is String) {
      if (vo2Max.contains('-')) {
        final parts = vo2Max.split('-');
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim());
          final max = double.tryParse(parts[1].trim());
          if (min != null && max != null) {
            return (min + max) / 2; // Return average
          }
        }
      }
      return double.tryParse(vo2Max);
    }
    return null;
  }

  /// Generates a [FitbitCardioScoreData] obtained from a json.
  factory FitbitCardioScoreData.fromJson({required Map<String, dynamic> json}) {
    final vo2Max = json['value']['vo2Max'];
    final calculatedValue = parseVo2Max(vo2Max);
    
    return FitbitCardioScoreData(
      userID: json['userID'],
      dateOfMonitoring: DateTime.parse(json['dateTime']),
      value: calculatedValue,
      rawValue: vo2Max?.toString(),
    );
  } // fromJson

  @override
  Map<String, dynamic> toJson<T extends FitbitData>() {
    return <String, dynamic>{
      'userID': userID,
      'dateTime': dateOfMonitoring,
       'value': <String, dynamic>{
        'vo2Max': rawValue ?? value?.toString(),
      },
    };
  } // toJson

  @override
  String toString() {
    return (StringBuffer('FitbitCardioScoreData(')
          ..write('userID: $userID, ')
          ..write('dateOfMonitoring: $dateOfMonitoring, ')
          ..write('value: $value, ')
          ..write('rawValue: $rawValue, ')
          ..write(')'))
        .toString();
  } // toString
} // FitbitCardioScoreData
