class AppInfo{

  String appName;
  String packageName;
  String version;
  String buildNumber;


  static final AppInfo _instance = AppInfo._internal();

  factory AppInfo() => _instance;

  AppInfo._internal();
}