import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/utils/exercise_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'username': 'alice'});
  });

  test('save then load / loadAll returns answers and session info', () async {
    await ExerciseProgressStore.save(
      7,
      {11: true, 12: false},
      sessionName: 'Loops',
      skillName: 'Python',
      skillIcon: 'code',
      totalQuestions: 5,
    );

    expect(await ExerciseProgressStore.load(7), {11: true, 12: false});

    final all = await ExerciseProgressStore.loadAll();
    expect(all, hasLength(1));
    expect(all.single.sessionId, 7);
    expect(all.single.sessionName, 'Loops');
    expect(all.single.skillName, 'Python');
    expect(all.single.skillIcon, 'code');
    expect(all.single.totalQuestions, 5);
    expect(all.single.updatedAt, isNotNull);
  });

  test('clear removes the session from loadAll', () async {
    await ExerciseProgressStore.save(7, {11: true}, totalQuestions: 3);
    await ExerciseProgressStore.clear(7);

    expect(await ExerciseProgressStore.load(7), isEmpty);
    expect(await ExerciseProgressStore.loadAll(), isEmpty);
  });

  test('progress of another user is not listed', () async {
    SharedPreferences.setMockInitialValues({
      'username': 'alice',
      'exercise_progress_bob_3': '{"answers":{"1":true},"total_questions":2}',
    });

    expect(await ExerciseProgressStore.loadAll(), isEmpty);
  });

  test('legacy format (plain id -> bool map) still loads', () async {
    SharedPreferences.setMockInitialValues({
      'username': 'alice',
      'exercise_progress_alice_9': '{"4":true,"5":false}',
    });

    expect(await ExerciseProgressStore.load(9), {4: true, 5: false});
    final all = await ExerciseProgressStore.loadAll();
    expect(all.single.sessionId, 9);
    expect(all.single.answers, {4: true, 5: false});
  });
}
