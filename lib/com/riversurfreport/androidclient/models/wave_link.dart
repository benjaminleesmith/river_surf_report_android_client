class WaveLink {
  String name;
  String url;

  WaveLink({this.name, this.url});

  factory WaveLink.fromJson(Map<String, dynamic> json) {
    return WaveLink(
        name: json['name'],
        url: json['url']
    );
  }
}