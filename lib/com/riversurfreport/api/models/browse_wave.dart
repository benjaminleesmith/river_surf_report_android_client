class BrowseWave {
  String name;
  String url;
  String parentsString;

  BrowseWave({this.name, this.url, this.parentsString});

  factory BrowseWave.fromJson(Map<String, dynamic> json) {
    return BrowseWave(
      name: json['name'],
      url: json['url'],
      parentsString: json['parents_string']
    );
  }
}