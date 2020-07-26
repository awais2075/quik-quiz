class Progress {
  int _currentPage = 0;
  int _totalPages = 0;
  int _currentQuestion = 0;
  int _totalQuestions = 0;

  Progress();

  int get totalQuestions => _totalQuestions;

  set totalQuestions(int value) {
    _totalQuestions = value;
  }

  int get currentQuestion => _currentQuestion;

  set currentQuestion(int value) {
    _currentQuestion = value;
  }

  int get totalPages => _totalPages;

  set totalPages(int value) {
    _totalPages = value;
  }

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
  }
}
