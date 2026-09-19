import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notas_v6/models/task.dart';
import 'package:notas_v6/utils/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> _taskBox;
  final TextEditingController _taskController = TextEditingController();
  bool _isEditing = false;
  Task? _taskToEdit;

  @override
  void initState() {
    super.initState();
    _initializeDB();
  }

  Future<void> _initializeDB() async {
    await DBHelper.init();
    _taskBox = await Hive.openBox<Task>('tasks');
    setState(() {});
  }

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _taskController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await _taskBox.add(newTask);
    _taskController.clear();
    setState(() {});
  }

  Future<void> _updateTask() async {
    if (_taskToEdit == null || _taskController.text.trim().isEmpty) return;

    _taskToEdit!.title = _taskController.text.trim();
    await _taskBox.put(_taskToEdit!.id, _taskToEdit!);
    _taskController.clear();
    _taskToEdit = null;
    _isEditing = false;
    setState(() {});
  }

  Future<void> _toggleTaskCompletion(String id) async {
    final task = await _taskBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await _taskBox.put(id, task);
      setState(() {});
    }
  }

  Future<void> _deleteTask(String id) async {
    await _taskBox.delete(id);
    setState(() {});
  }

  void _startEditing(Task task) {
    _taskToEdit = task;
    _taskController.text = task.title;
    _isEditing = true;
  }

  void _cancelEditing() {
    _taskController.clear();
    _taskToEdit = null;
    _isEditing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas V6'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _initializeDB();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: _isEditing ? 'Editar tarefa' : 'Adicionar nova tarefa',
                suffixIcon: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _updateTask,
                      )
                    : null,
              ),
              onSubmitted: (_) {
                if (_isEditing) {
                  _updateTask();
                } else {
                  _addTask();
                }
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: Hive.box<Task>('tasks').listenable(),
              builder: (context, box, _) {
                final tasks = box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await _deleteTask(task.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tarefa removida'),
                            action: SnackBarAction(
                              label: 'Desfazer',
                              onPressed: () async {
                                await _taskBox.add(task);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                      child: CheckboxListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        value: task.isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(task.id),
                        secondary: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEditing(task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _cancelEditing();
          } else {
            _addTask();
          }
        },
        child: Icon(_isEditing ? Icons.cancel : Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}