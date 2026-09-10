import 'package:flutter_test/flutter_test.dart';
import 'package:flowspace/features/tasks/domain/task_model.dart';
import 'package:flowspace/features/tasks/data/task_repository_impl.dart';
import 'package:flowspace/features/calendar/domain/calendar_event_model.dart';
import 'package:flowspace/features/calendar/data/calendar_repository_impl.dart';
import 'package:flowspace/features/notes/domain/editor_block_model.dart';
import 'package:flowspace/features/notes/domain/note_page_model.dart';
import 'package:flowspace/features/notes/data/notes_repository_impl.dart';
import 'package:flowspace/features/projects/domain/project_model.dart';
import 'package:flowspace/features/projects/data/project_repository_impl.dart';
import 'package:flowspace/features/reminders/domain/reminder_model.dart';
import 'package:flowspace/features/reminders/data/reminder_repository_impl.dart';

void main() {
  group('Tasks Repository & Model Tests', () {
    test('Task creation, completion toggle, and bulk operations', () async {
      final repo = TaskRepositoryImpl();
      final initialTasks = await repo.getTasks();
      expect(initialTasks.isNotEmpty, true);

      final now = DateTime.now();
      final newTask = Task(
        id: 'test-task-1',
        title: 'Unit Test Task',
        description: 'Verify task creation',
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createTask(newTask);
      final fetched = await repo.getTaskById('test-task-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Unit Test Task');
      expect(fetched.priority, TaskPriority.high);

      // Bulk complete
      await repo.bulkComplete(['test-task-1']);
      final completed = await repo.getTaskById('test-task-1');
      expect(completed!.isCompleted, true);
      expect(completed.status, TaskStatus.completed);

      // Delete
      await repo.deleteTask('test-task-1');
      final afterDelete = await repo.getTaskById('test-task-1');
      expect(afterDelete, isNull);
    });
  });

  group('Calendar Repository Tests', () {
    test('Event creation, range queries, and duplicate', () async {
      final repo = CalendarRepositoryImpl();
      final now = DateTime.now();
      final event = CalendarEvent(
        id: 'test-ev-1',
        title: 'Team Sync',
        startDateTime: now,
        endDateTime: now.add(const Duration(hours: 1)),
        colorValue: 0xFF6366F1,
        calendarId: 'cal-work',
        createdAt: now,
        updatedAt: now,
      );

      await repo.createEvent(event);
      final rangeEvents = await repo.getEventsForRange(
        now.subtract(const Duration(minutes: 5)),
        now.add(const Duration(hours: 2)),
      );
      expect(rangeEvents.any((e) => e.id == 'test-ev-1'), true);

      // Duplicate
      final dup = await repo.duplicateEvent('test-ev-1');
      expect(dup.title, 'Team Sync (Copy)');
    });
  });

  group('Notion Notes & Blocks Repository Tests', () {
    test('Page creation, block reordering, and favorite toggle', () async {
      final repo = NotesRepositoryImpl();
      final now = DateTime.now();
      final page = NotePage(
        id: 'test-page-1',
        title: 'Project Wiki',
        icon: '📚',
        blocks: [
          EditorBlock(
            id: 'b1',
            type: BlockType.heading1,
            content: 'Title',
            createdAt: now,
            updatedAt: now,
          ),
          EditorBlock(
            id: 'b2',
            type: BlockType.text,
            content: 'Paragraph',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      await repo.createPage(page);
      await repo.reorderBlocks('test-page-1', 0, 2);

      final updated = await repo.getPageById('test-page-1');
      expect(updated!.blocks.first.id, 'b2');

      await repo.toggleFavorite('test-page-1');
      final favPage = await repo.getPageById('test-page-1');
      expect(favPage!.isFavorite, true);
    });
  });

  group('Projects Repository Tests', () {
    test('Project creation and status tracking', () async {
      final repo = ProjectRepositoryImpl();
      final now = DateTime.now();
      final project = Project(
        id: 'test-proj-1',
        name: 'AI Agent System',
        icon: '🤖',
        colorValue: 0xFF8B5CF6,
        status: ProjectStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createProject(project);
      final fetched = await repo.getProjectById('test-proj-1');
      expect(fetched!.name, 'AI Agent System');
      expect(fetched.status, ProjectStatus.active);
    });
  });

  group('Reminders Repository Tests', () {
    test('Reminder snooze and completion', () async {
      final repo = ReminderRepositoryImpl();
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'test-rem-1',
        title: 'Focus Sprint Alarm',
        scheduledAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createReminder(reminder);
      await repo.snoozeReminder('test-rem-1', const Duration(minutes: 15));

      final snoozed = await repo.getReminderById('test-rem-1');
      expect(snoozed!.isSnoozed, true);
      expect(snoozed.snoozeUntil, isNotNull);

      await repo.completeReminder('test-rem-1');
      final done = await repo.getReminderById('test-rem-1');
      expect(done!.isCompleted, true);
    });
  });
}
