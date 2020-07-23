import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/category.dart';

class CategoryMap {

  STATUS _status;
  List<Category> _categories;

  CategoryMap(this._status, this._categories);

  List<Category> get categories => _categories;

  set categories(List<Category> value) {
    _categories = value;
  }

  STATUS get status => _status;

  set status(STATUS value) {
    _status = value;
  }
}