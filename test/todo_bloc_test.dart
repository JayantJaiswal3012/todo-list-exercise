import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_list/blocs/todo_bloc.dart';
import 'package:todo_list/blocs/todo_events.dart';
import 'package:todo_list/blocs/todo_states.dart';
import 'package:todo_list/models/todo_item_model.dart';
import 'package:todo_list/repository/todo_repository.dart';
import 'package:todo_list/util/notification_helper.dart';

class MockTodosRepository extends Mock implements FirestoreTodosRepository {}

class MockNotificationManager extends Mock implements NotificationManager {}

void main() {
  group('TodosBloc', () {
    FirestoreTodosRepository todosRepository;
    TodosBloc todosBloc;
    NotificationManager notificationManager;

    setUp(() {
      todosRepository = MockTodosRepository();
      notificationManager = MockNotificationManager();

      when(todosRepository.loadTodos()).thenAnswer((_) => Future.value([]));
      todosBloc = TodosBloc(
          todosRepository: todosRepository,
          notificationManager: notificationManager);
    });

    blocTest(
      'exception while loading todos',
      build: () {
        when(todosRepository.loadTodos()).thenThrow(Exception('oops'));
        return todosBloc;
      },
      act: (TodosBloc bloc) async => bloc.add(LoadTodos()),
      expect: <TodosState>[
        TodosNotLoaded(),
      ],
    );

    blocTest(
      'create todo on CreateTodo Event',
      build: () {
        when(notificationManager.scheduleNotification(any, any, any))
            .thenAnswer((_) => Future.value([]));
        return todosBloc;
      },
      act: (TodosBloc bloc) async => bloc
        ..add(LoadTodos())
        ..add(CreateTodo(
            TodoItem('todo', id: '0', reminderDate: ""), DateTime.now())),
      expect: <TodosState>[
        TodosLoaded([]),
        TodosLoaded([TodoItem('todo', id: '0', reminderDate: "")]),
      ],
    );

    blocTest(
      'delete on DeleteTodo Event',
      build: () {
        when(todosRepository.loadTodos()).thenAnswer((_) => Future.value([]));
        return todosBloc;
      },
      act: (TodosBloc bloc) async {
        final todo = TodoItem('todo', id: '0', reminderDate: "");
        bloc
          ..add(LoadTodos())
          ..add(CreateTodo(todo, DateTime.now()))
          ..add(DeleteTodo(0));
      },
      expect: <TodosState>[
        TodosLoaded([]),
        TodosLoaded([TodoItem('todo', id: '0', reminderDate: "")]),
        TodosLoaded([]),
      ],
    );

    blocTest(
      'reorder list on ReorderTodos event',
      build: () => todosBloc,
      act: (TodosBloc bloc) async {
        final todo1 = TodoItem('todo 1', id: '0', reminderDate: "");
        final todo2 = TodoItem('todo 2', id: '1', reminderDate: "");
        bloc
          ..add(LoadTodos())
          ..add(CreateTodo(todo1, DateTime.now()))
          ..add(CreateTodo(todo2, DateTime.now()))
          ..add(ReorderTodos(0, 1));
      },
      expect: <TodosState>[
        TodosLoaded([]),
        TodosLoaded([TodoItem('todo 1', id: '0', reminderDate: "")]),
        TodosLoaded([
          TodoItem('todo 2', id: '1', reminderDate: ""),
          TodoItem('todo 1', id: '0', reminderDate: "")
        ]),
        TodosLoaded([
          TodoItem('todo 1', id: '0', reminderDate: ""),
          TodoItem('todo 2', id: '1', reminderDate: "")
        ]),
      ],
    );

   /* blocTest(
      'mark as done on MarkDone event',
      build: () => todosBloc,
      act: (TodosBloc bloc) async {
        final todo1 = TodoItem('todo 1', id: '0', reminderDate: "");
        final todo2 = TodoItem('todo 2', id: '1', reminderDate: "");
        final todo3 = TodoItem('todo 3', id: '2', reminderDate: "");
        bloc
          ..add(LoadTodos())
          ..add(CreateTodo(todo1, DateTime.now()))
          ..add(CreateTodo(todo2, DateTime.now()))
          ..add(CreateTodo(todo3, DateTime.now()))
          ..add(MarkDone(0));
      },
      expect: <TodosState>[
        TodosLoaded([]),
        TodosLoaded([TodoItem('todo 1', id: '0', isActive: true)]),
        TodosLoaded([
          TodoItem('todo 2', id: '1', isActive: true),
          TodoItem('todo 1', id: '0', isActive: true)
        ]),
        TodosLoaded([
          TodoItem('todo 3', id: '2', isActive: true),
          TodoItem('todo 2', id: '1', isActive: true),
          TodoItem('todo 1', id: '0', isActive: true)
        ]),
        TodosLoaded([
          TodoItem('todo 2', id: '1', isActive: true),
          TodoItem('todo 1', id: '0', isActive: true),
          TodoItem('todo 3', isActive: false),
        ]),
      ],
    );*/
  });
}
