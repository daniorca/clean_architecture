import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/core/error/failures.dart';
import 'package:clean_architecture/core/network/network_info.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('Get Concrete Number trivia', () {
    final tNumber = 1;
    final tNumberTrivialModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTrivialModel;
    test('should check if the device is online', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is success',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTrivialModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is success',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTrivialModel);
        //act
        await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivialModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cache data is present',
          () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTrivialModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
