import 'package:flutterqaapp/models/question.dart';

class QuestionMap{

 static final QuestionMap _instance = QuestionMap._internal();

 Map<String, Map<int,List<Question>>> map= Map();
 Map<String,int> categoryMap = Map();
  factory QuestionMap(){

    return _instance;
  }


 QuestionMap._internal();
}