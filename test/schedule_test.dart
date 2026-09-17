import 'package:flutter_test/flutter_test.dart';
import 'package:flowspace/features/schedules/domain/schedule_model.dart';

void main() {
  group('ScheduleModel Multi-Dimensional Tests', () {
    final now = DateTime.now();

    test('Delay mode model creation and JSON serialization', () {
      final schedule = ScheduleModel(
        id: 'delay-1',
        userId: 'user-1',
        title: 'Review PR',
        mode: ScheduleMode.delay,
        delayOffset: '2 hours',
        status: ScheduleStatus.active,
        createdAt: now,
      );

      expect(schedule.mode, ScheduleMode.delay);
      expect(schedule.delayOffset, '2 hours');
      expect(schedule.timingDescription, '+2 hours');
      expect(schedule.isActive, true);

      final json = schedule.toJson();
      final revived = ScheduleModel.fromJson(json);

      expect(revived.id, 'delay-1');
      expect(revived.mode, ScheduleMode.delay);
      expect(revived.delayOffset, '2 hours');
    });

    test('Time-Bounded mode model creation', () {
      final start = now.add(const Duration(hours: 1));
      final end = now.add(const Duration(hours: 3));

      final schedule = ScheduleModel(
        id: 'bounded-1',
        userId: 'user-1',
        title: 'Planning Session',
        mode: ScheduleMode.bounded,
        windowStart: start,
        windowEnd: end,
        status: ScheduleStatus.active,
        createdAt: now,
      );

      expect(schedule.mode, ScheduleMode.bounded);
      expect(schedule.windowStart, start);
      expect(schedule.windowEnd, end);
      expect(schedule.timingDescription.contains('→'), true);
    });

    test('Recurrent mode model creation with RRULE', () {
      final schedule = ScheduleModel(
        id: 'routine-1',
        userId: 'user-1',
        title: 'Morning Focus',
        mode: ScheduleMode.recurrent,
        rrule: 'FREQ=DAILY;INTERVAL=1',
        status: ScheduleStatus.active,
        createdAt: now,
      );

      expect(schedule.mode, ScheduleMode.recurrent);
      expect(schedule.rrule, 'FREQ=DAILY;INTERVAL=1');
      expect(schedule.timingDescription, 'FREQ=DAILY;INTERVAL=1');
    });

    test('Dependent mode model tracks blocked state', () {
      final schedule = ScheduleModel(
        id: 'dependent-1',
        userId: 'user-1',
        title: 'Deploy Production',
        mode: ScheduleMode.dependent,
        prerequisiteId: 'delay-1',
        status: ScheduleStatus.blocked,
        createdAt: now,
      );

      expect(schedule.mode, ScheduleMode.dependent);
      expect(schedule.prerequisiteId, 'delay-1');
      expect(schedule.isBlocked, true);
      expect(schedule.isActive, false);
    });
  });
}