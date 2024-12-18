import 'package:flai_quiz/models/quiz.dart';
import 'package:flai_quiz/utils/config.dart';
import 'package:flai_quiz/models/category.dart';

import 'base_api_dio.dart';

class QuizApiDio extends BaseApiDio {
  QuizApiDio()
      : super(
          baseApiUrl: config.host,
          timeoutMillis: 60000,
        );

  Future<Query?> getQuiz({
    required String category,
    required String total,
    required String difficulty,
  }) async {
    final path =
        '?amount=$total&category=$category&difficulty=$difficulty&type=multiple';
    return await get<Query?>(
      path: path,
    );
  }
}
