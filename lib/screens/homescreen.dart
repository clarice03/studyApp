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

  Future<void> saveTasks() async {
    await taskBox.put('tasks', tasks);
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

  Widget buildTaskCard(Map<String, dynamic> task) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
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
        title: Text(
          task["title"],
          style: TextStyle(
            decoration:
                task["done"] ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text("Due: ${task["deadline"]}"),
        trailing: Container(
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

      // ✅ IMPROVED EMPTY STATE
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.menu_book,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No tasks yet!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tap + to add one 📚",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📚 Your Study Tasks",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Pending Tasks",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: [
                        ...pending.map(buildTaskCard),

                        const SizedBox(height: 20),

                        const Text(
                          "Completed",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 10),

                        ...done.map(buildTaskCard),
                      ],
                    ),
                  ),
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