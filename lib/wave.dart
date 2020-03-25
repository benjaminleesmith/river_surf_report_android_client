class Wave {
  String name;
  String url;

  Wave({this.name, this.url});

  factory Wave.fromJson(Map<String, dynamic> json) {
    return Wave(
      name: json['name'],
      url: json['url']
    );
  }
}