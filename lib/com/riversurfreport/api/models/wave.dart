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
        minFlow: json['minFlow'].toDouble(),
        maxFlow: json['maxFlow'].toDouble(),
        flow: json['flow'].toDouble(),
        flowTimestamp: DateTime.parse(json['flowTimestamp']),
        flowUnitOfMeasurement: json['flowUnitOfMeasurement'],
    );
  }
}