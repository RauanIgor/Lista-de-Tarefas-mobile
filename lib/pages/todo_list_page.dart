import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController guestListController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todoList = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todoList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Lista De Tarefas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: const Color(0xff127369),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: guestListController,
                        decoration: InputDecoration(
                          errorText: errorText,
                          labelText: 'Adicione uma tarefa',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff127369),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = guestListController.text;
                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'Esse campo não pode estar vazio';
                          });
                          return;
                        }
                        setState(() {
                          Todo newTodo =
                              Todo(title: text, dateTime: DateTime.now());
                          todoList.add(newTodo);
                          errorText = null;
                        });
                        guestListController.clear();
                        todoRepository.saveTodoList(todoList);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff127369),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todoList)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          "Total de ${todoList.length} tarefas para fazer"),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: showDeleteTodosConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff127369),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'Limpar Tudo',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todoList.indexOf(todo);
    setState(() {
      todoList.remove(todo);
    });

    todoRepository.saveTodoList(todoList);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title.toUpperCase()}, removida com sucesso',
          style: const TextStyle(
            color: Color(0xffffffff),
          ),
        ),
        backgroundColor: const Color(0xff127369),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              todoList.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todoList);
          },
          textColor: const Color(0xffffffff),
        ),
      ),
    );
  }

  void showDeleteTodosConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar tudo?'),
        content: const Text('Deseja romover todas as tarefas da lista?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff127369),
            ),
            child: const Text(
              'Cancelar',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFE4A49),
            ),
            child: const Text(
              'Limpar Tudo',
            ),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todoList.clear();
    });
    todoRepository.saveTodoList(todoList);
  }
}
