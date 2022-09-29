import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

import '../../../../fixtures/fixture_reader.dart';

@GenerateMocks([http.Client])
import 'number_trivia_remote_datasource_test.mocks.dart';

void main() {
  late NumberTriviaRemoteDataSourceImpl datasource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    datasource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    var uri = Uri.parse('http://numbersapi.com/$tNumber');
    test('''should perform a GET request on a URL with number
     being the endpoint and with application/json header''', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      datasource.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockHttpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });

    test('should return number trivia when the response code is 200 (success)',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await datasource.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other than 200',
        () async {
      //arrange
      setUpMockHttpClientFailure404();
      //act
      final call = datasource.getConcreteNumberTrivia;
      //assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    var uri = Uri.parse('http://numbersapi.com/random');
    test('''should perform a GET request on a URL random
     being the endpoint and with application/json header''', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      datasource.getRandomNumberTrivia();
      //assert
      verify(mockHttpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });

    test('should return number trivia when the response code is 200 (success)',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await datasource.getRandomNumberTrivia();
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other than 200',
        () async {
      //arrange
      setUpMockHttpClientFailure404();
      //act
      final call = datasource.getRandomNumberTrivia;
      //assert
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}
