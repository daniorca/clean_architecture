import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

@GenerateMocks([SharedPreferences])
import 'number_trivia_local_datasource_test.mocks.dart';

void main() {
  late NumberTriviaLocalDataSourceImpl datasource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      //arrange
      when(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(fixture('trivia_cached.json'));
      //act
      final result = await datasource.getLastNumberTrivia();
      //assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });
    test('should throw a CacheException when there is not a cache value',
        () async {
      //arrange
      when(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(null);
      //act
      final call = datasource.getLastNumberTrivia;
      //assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 1);
    final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
    test('should call SharedPreferences to cache the data', () async {
      //arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      //act
      datasource.cacheNumberTrivia(tNumberTriviaModel);
      //assert

      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
