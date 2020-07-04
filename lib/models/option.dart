class Option {
  String _text;
  bool _isTrue;

  Option({String text, bool isTrue}) {
    this._text = text;
    this._isTrue = isTrue;
  }

  String get text => _text;

  set text(String text) => _text = text;

  bool get isTrue => _isTrue;

  set isTrue(bool isTrue) => _isTrue = isTrue;

  Option.fromJson(Map<String, dynamic> json) {
    _text = json['text'];
    _isTrue = json['isTrue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this._text;
    data['isTrue'] = this._isTrue;
    return data;
  }
}
