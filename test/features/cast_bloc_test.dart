import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/core/network/api_exceptions.dart';
import 'package:tv_maze_application/domain/entities/cast_member.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';
import 'package:tv_maze_application/features/cast/bloc/cast_bloc.dart';
import 'package:tv_maze_application/features/cast/bloc/cast_event.dart';
import 'package:tv_maze_application/features/cast/bloc/cast_state.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository mockShowRepository;
  late CastBloc castBloc;

  setUp(() {
    mockShowRepository = MockShowRepository();
    castBloc = CastBloc(showRepository: mockShowRepository);
  });

  tearDown(() {
    castBloc.close();
  });

  const testCast = [
    CastMember(
      personId: 1,
      personName: 'Mike Vogel',
      characterId: 1,
      characterName: 'Dale Barbara',
    ),
  ];

  group('CastBloc', () {
    test('initial state is CastInitial', () {
      expect(castBloc.state, const CastInitial());
    });

    blocTest<CastBloc, CastState>(
      'emits [CastLoading, CastLoaded] on successful fetch',
      build: () {
        when(() => mockShowRepository.getShowCast(1))
            .thenAnswer((_) async => testCast);
        return castBloc;
      },
      act: (bloc) => bloc.add(const CastRequested(1)),
      expect: () => [
        const CastLoading(),
        const CastLoaded(testCast),
      ],
      verify: (_) {
        verify(() => mockShowRepository.getShowCast(1)).called(1);
      },
    );

    blocTest<CastBloc, CastState>(
      'emits [CastLoading, CastEmpty] when cast list is empty',
      build: () {
        when(() => mockShowRepository.getShowCast(1))
            .thenAnswer((_) async => []);
        return castBloc;
      },
      act: (bloc) => bloc.add(const CastRequested(1)),
      expect: () => [
        const CastLoading(),
        const CastEmpty(),
      ],
    );

    blocTest<CastBloc, CastState>(
      'emits [CastLoading, CastError] on failure',
      build: () {
        when(() => mockShowRepository.getShowCast(1))
            .thenThrow(const ServerException('Server error'));
        return castBloc;
      },
      act: (bloc) => bloc.add(const CastRequested(1)),
      expect: () => [
        const CastLoading(),
        const CastError('Server error'),
      ],
    );

    blocTest<CastBloc, CastState>(
      'retries fetching cast on CastRetryRequested',
      build: () {
        when(() => mockShowRepository.getShowCast(1))
            .thenAnswer((_) async => testCast);
        return castBloc;
      },
      seed: () => const CastError('Failed'),
      act: (bloc) => bloc.add(const CastRetryRequested(1)),
      expect: () => [
        const CastLoading(),
        const CastLoaded(testCast),
      ],
    );
  });
}
