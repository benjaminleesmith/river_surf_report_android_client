class Wave {
  String name;
  String reportsUrl;
  String createReportUrl;
  String flowUrl;
  double minFlow;
  double maxFlow;
  double flow;
  DateTime flowTimestamp;
  String flowUnitOfMeasurement;

  Wave({this.name, this.reportsUrl, this.createReportUrl, this.flowUrl,
      this.minFlow, this.maxFlow, this.flow, this.flowTimestamp,
      this.flowUnitOfMeasurement});

  factory Wave.fromJson(Map<String, dynamic> json) {
    return Wave(
        name: json['name'],
        reportsUrl: json['reportsUrl'],
        createReportUrl: json['createReportUrl'],
        flowUrl: json['flowUrl'],
        minFlow: json['minFlow']?.toDouble() ?? 0.0,
        maxFlow: json['maxFlow']?.toDouble() ?? 0.0,
        flow: json['flow']?.toDouble() ?? 0.0,
        flowTimestamp: json['flowTimestamp'] == null ? null : DateTime.parse(json['flowTimestamp']),
        flowUnitOfMeasurement: json['flowUnitOfMeasurement'],
    );
  }
}