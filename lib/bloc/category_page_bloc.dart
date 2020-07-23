import 'dart:async';
import 'dart:convert';

import 'package:flutterqaapp/enums/status.dart';
import 'package:flutterqaapp/models/category_map.dart';
import 'package:flutterqaapp/models/category_result.dart';
import 'package:flutterqaapp/utils/constants.dart';
import 'package:http/http.dart' as http;

class CategoryPageBloc {
  final _categoriesWidgetController = StreamController<CategoryMap>.broadcast();

  Stream<CategoryMap> get categoriesWidgetStream =>
      _categoriesWidgetController.stream;

  StreamSink<CategoryMap> get _categoriesWidgetSink =>
      _categoriesWidgetController.sink;

  final _loadCategoriesWidgetController = StreamController.broadcast();

  StreamSink get loadCategoriesWidgetSink =>
      _loadCategoriesWidgetController.sink;

  CategoryPageBloc() {
    _loadCategoriesWidgetController.stream.listen((_) {
      _loadCategories();
    });
  }

  void dispose() {
    _categoriesWidgetController.close();
    _loadCategoriesWidgetController.close();
  }

  _loadCategories() async {
    _categoriesWidgetSink.add(CategoryMap(STATUS.LOADING, null));
    await http.get('$BASE_URL/categories').then((response) {
      CategoryResult result =
          CategoryResult.fromJson(json.decode(response.body));
      _categoriesWidgetSink.add(CategoryMap(STATUS.SUCCESS, result.body));
    }).catchError((error) {
      print(error.message);

      _categoriesWidgetSink.add(CategoryMap(STATUS.FAIL, null));
    });
  }
}
