import 'package:awesome_notifications/awesome_notifications.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';

import 'add_task_screen.dart';
import 'database_helper.dart';
import 'main.dart';
import 'task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat("MMM dd, yyyy, hh:mm");

  late int completedTaskCount = 0;
  late int allTaskCount = 0;

  bool orderBy = false;
  bool filterBy = false;

  Widget _buildItem(Task task) {
    return Container(
      color: const Color.fromARGB(45, 0, 0, 0),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskScreen(
              updateTaskList: _updateTaskList,
              task: task,
            ),
          ),
        ),
        title: Text(
          task.title!,
          style: TextStyle(
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough),
        ),
        subtitle: Text(
          _dateFormat.format(task.date),
          style: TextStyle(
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough),
        ),
        trailing: Checkbox(
          value: task.status == 0 ? false : true,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (bool? value) {
            if (value != null) {
              task.status = value ? 1 : 0;
            }
            DatabaseHelper.instance.updateTask(task);
            _updateTaskList();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Allow notification'),
          content: const Text('This app wants to show notification'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Dont Allow",
                style: TextStyle(color: Colors.green, fontSize: 10),
              ),
            ),
            TextButton(
              onPressed: () {
                AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((value) => Navigator.pop(context));
              },
              child: const Text(
                "Allow",
                style: TextStyle(color: Colors.green, fontSize: 10),
              ),
            ),
          ],
        ),
      );
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onActionReceivedMethod(receivedAction);
      },
      onNotificationCreatedMethod:
          (ReceivedNotification receivedNotification) async {
        NotificationController.onNotificationCreatedMethod(
            receivedNotification);
      },
      onNotificationDisplayedMethod:
          (ReceivedNotification receivedNotification) async {
        NotificationController.onNotificationDisplayedMethod(
            receivedNotification);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onDismissActionReceivedMethod(receivedAction);
      },
    );

    // AwesomeNotifications().createdStream.listen((notification) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification created")),);
    // });

    // @pragma("vm:entry-point")
    // Future<void> onNotificationCreatedMethod(
    //     ReceivedNotification receivedNotification) async {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Notification created")),
    //   );
    // }
    //
    // @pragma("vm:entry-point")
    // Future<void> onNotificationDisplayedMethod(
    //     ReceivedNotification receivedNotification) async {
    //   AwesomeNotifications()
    //       .getGlobalBadgeCounter()
    //       .then((value) => AwesomeNotifications().setGlobalBadgeCounter(value));
    // }

    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance
          .getTaskList(orderByDate: orderBy, filterByStatus: filterBy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AddTaskScreen(updateTaskList: _updateTaskList))),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    const Text(
                      "My Task",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "$completedTaskCount/$allTaskCount",
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Row(
                  children: [
                    const Text("Orber by date"),
                    Checkbox(
                      value: orderBy,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          orderBy = value;
                          orderBy
                              ? DatabaseHelper.instance
                                  .getTaskList(orderByDate: true)
                              : DatabaseHelper.instance
                                  .getTaskList(orderByDate: false);
                        }
                        _updateTaskList();
                      },
                    ),

                    //////////////////////////////////////////////////////
                    const Text("filter by status"),
                    Checkbox(
                      value: filterBy,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          filterBy = value;
                          filterBy
                              ? DatabaseHelper.instance
                                  .getTaskList(filterByStatus: true)
                              : DatabaseHelper.instance
                                  .getTaskList(filterByStatus: false);
                        }
                        _updateTaskList();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: _taskList,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                          itemCount:
                              snapshot.data != null ? snapshot.data.length : 0,
                          itemBuilder: (BuildContext context, int index) {
                            Future.delayed(Duration.zero, () async {
                              setState(() {
                                allTaskCount = snapshot.data.length;
                                completedTaskCount = snapshot.data
                                    .where((Task task) => task.status == 1)
                                    .toList()
                                    .length;
                              });
                            });

                            return _buildItem(snapshot.data[index]);
                          });
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
