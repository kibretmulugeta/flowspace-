import 'schedule_model.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleModel>> getSchedules({ScheduleMode? mode, ScheduleStatus? status});
  Future<ScheduleModel?> getScheduleById(String id);
  Future<ScheduleModel> createSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
  Future<ScheduleModel> completeSchedule(String id);
  Future<List<ScheduleModel>> getDependentSchedules(String prerequisiteId);
}