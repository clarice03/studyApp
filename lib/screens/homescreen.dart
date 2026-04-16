import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../notificationService.dart';
import 'addTaskScreen.dart';
import 'librariesScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final Box taskBox = Hive.box('tasksBox');

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTasks();
  }

  // ✅ FIXED LOAD (safe + no crash + persistent)
  void loadTasks() {
    final data = taskBox.get('tasks');

    if (data == null) {
      setState(() {
        tasks = [];
      });
      return;
    }

    setState(() {
      tasks = List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      );
    });
  }

  // ✅ FIXED SAVE (IMPORTANT)
  Future<void> saveTasks() async {
    await taskBox.put('tasks', tasks);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      saveTasks();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    saveTasks();
    super.dispose();
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Future<void> navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(Map<String, dynamic>.from(newTask));
      });

      await saveTasks();

      await NotificationService.showNotification(
        title: "Task Added",
        body: newTask["title"],
      );
    }
  }

  void editTaskDialog(Map<String, dynamic> task) {
    TextEditingController controller =
        TextEditingController(text: task["title"]);

    String tempPriority = task["priority"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller),
              DropdownButtonFormField<String>(
                value: tempPriority,
                items: const [
                  DropdownMenuItem(value: "High", child: Text("High")),
                  DropdownMenuItem(value: "Medium", child: Text("Medium")),
                  DropdownMenuItem(value: "Low", child: Text("Low")),
                ],
                onChanged: (value) {
                  tempPriority = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  task["title"] = controller.text;
                  task["priority"] = tempPriority;
                });

                await saveTasks();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget buildTaskCard(Map<String, dynamic> task) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task["done"],
          onChanged: (value) async {
            setState(() {
              task["done"] = value;
            });

            await saveTasks();

            if (value == true) {
              await NotificationService.showNotification(
                title: "Task Completed 🎉",
                body: task["title"],
              );
            }
          },
        ),
        title: Text(task["title"]),
        subtitle: Text("Due: ${task["deadline"]}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: getPriorityColor(task["priority"]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task["priority"],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => editTaskDialog(task),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                setState(() {
                  tasks.remove(task);
                });

                await saveTasks();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => t["done"] == false).toList();
    final done = tasks.where((t) => t["done"] == true).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Exam Planner")),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Exam Planner",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Task"),
              onTap: () {
                Navigator.pop(context);
                navigateToAddTask();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Libraries"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LibrariesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              "Pending Tasks",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ...pending.map(buildTaskCard),

            const SizedBox(height: 20),

            const Text(
              "Done",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ...done.map(buildTaskCard),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}