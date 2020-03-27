
import 'package:river_surf_report_client/com/riversurfreport/androidclient/models/wave.dart';

class Report {
  Wave wave;
  DateTime date;
  String flow = "666 CFS";
  String imageUrl =
      "http://localhost:3009/IMG_0994.JPG?foo=http://dsjp3ji7yf435.cloudfront.net/";
  String unlikeReportUrl;
  String likeReportUrl;
  String flagReportUrl;
  int stars;
  String notes;
  int likes;

  Report(
      {this.wave,
      this.date,
      this.flow,
      this.imageUrl,
      this.unlikeReportUrl,
      this.likeReportUrl,
      this.flagReportUrl,
      this.stars,
      this.notes,
      this.likes});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
        wave: Wave.fromJson(json['wave']),
        date: DateTime.parse(json['date']),
        flow: json['flow'],
        imageUrl: json['imageUrl'],
        unlikeReportUrl: json['unlikeReportUrl'],
        likeReportUrl: json['likeReportUrl'],
        flagReportUrl: json['flagReportUrl'],
        stars: json['stars'],
        notes: json['notes'],
        likes: json['likes']);
  }
}
