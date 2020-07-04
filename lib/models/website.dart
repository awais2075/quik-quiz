class Website{
  String _name;
  String _url;

  Website(this._name, this._url);

  String get url => _url;

  set url(String value) {
    _url = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}