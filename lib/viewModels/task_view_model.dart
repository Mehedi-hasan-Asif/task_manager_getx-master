import 'package:get/get.dart';
import 'package:task_manager_getx/models/responseModel/success.dart';
import 'package:task_manager_getx/models/taskListModel/task_data.dart';
import 'package:task_manager_getx/models/taskListModel/task_list_model.dart';
import 'package:task_manager_getx/models/taskStatusCountModels/task_status_count_model.dart';
import 'package:task_manager_getx/services/task_service.dart';
import 'package:task_manager_getx/utils/app_strings.dart';
import 'package:task_manager_getx/viewModels/dashboard_view_model.dart';

import '../models/taskStatusCountModels/status_data.dart';

class TaskViewModel extends GetxController {
  List<StatusData> _taskStatusData = [];
  List<String> taskList = [
    AppStrings.taskStatusNew,
    AppStrings.taskStatusCompleted,
    AppStrings.taskStatusProgress,
    AppStrings.taskStatusCanceled
  ];
  Map<String, List<TaskData>> _taskDataByStatus = {};
  final Map<String, int> _badgeCount = {
    AppStrings.taskStatusNew: 0,
    AppStrings.taskStatusProgress: 0,
    AppStrings.taskStatusCompleted: 0,
    AppStrings.taskStatusCanceled: 0
  };
  Map<String, String> taskStatusCount = {};
  Map<String, int> selectedIndex = {};
  bool _isLoading = false;

  late Object response;
  TaskService taskService = TaskService();

  bool get isLoading => _isLoading;

  List<StatusData> get taskStatusData => _taskStatusData;

  Map<String, List<TaskData>> get taskDataByStatus => _taskDataByStatus;

  int? getBadgeCount(String taskStatus) => _badgeCount[taskStatus];

  void setIsLoading(bool value) {
    _isLoading = value;
    update();
  }

  void resetTaskData() {
    _taskDataByStatus = {};
    taskStatusCount = {};
  }

  void setIsTileExpanded(String taskStatus, int index, bool value) {
    _taskDataByStatus[taskStatus]![index].isTileExpanded = value;
    update();
  }

  Future<void> fetchTaskStatusData(String token) async {
    response = await taskService.fetchTaskStatusCount(token);
    if (response is Success) {
      TaskStatusCountModel taskStatusCountModel = TaskStatusCountModel.fromJson(
          (response as Success).response as Map<String, dynamic>);
      if (taskStatusCountModel.statusData != null &&
          taskStatusCountModel.statusData!.isNotEmpty) {
        _taskStatusData =
            List.from(taskStatusCountModel.statusData as Iterable);
        taskStatusCount = {};
        for (StatusData data in _taskStatusData) {
          if (data.sId != null) {
            taskStatusCount[data.sId.toString()] = data.sum.toString();
          }
        }
      }
    }
  }

  Future<void> fetchTaskList(String token) async {
    for (String taskStatus in taskList) {
      response = await taskService.fetchTaskList(taskStatus, token);
      if (response is Success) {
        TaskListModel taskListModel = TaskListModel.fromJson(
            (response as Success).response as Map<String, dynamic>);
        if (taskListModel.taskData != null) {
          List<TaskData> taskData =
              List.from(taskListModel.taskData as Iterable);
          _taskDataByStatus[taskStatus] = taskData.reversed.toList();
        }
      }
    }
    update();
  }

  Future<bool> createTask(
      String token, String taskSubject, String taskDescription) async {
    setIsLoading(true);
    Map<String, String> taskData = {
      "title": taskSubject,
      "description": taskDescription,
      "status": AppStrings.taskStatusNew
    };
    response = await taskService.createTask(token, taskData);
    if (response is Success) {
      Map<String, dynamic> jsonData =
          (response as Success).response as Map<String, dynamic>;
      TaskData taskData = TaskData.fromJson(jsonData["data"]);
      String? generatedDate = taskData.createdDate?.substring(0, 10);
      List<String> date = generatedDate?.split("-") ?? [];
      date.insert(0, date.removeAt(2));
      date.insert(1, date.removeAt(2));
      taskData.createdDate = date.join("-");
      _taskDataByStatus[AppStrings.taskStatusNew]?.insert(0, taskData);
      taskStatusCount[AppStrings.taskStatusNew] =
          ((int.parse(taskStatusCount[AppStrings.taskStatusNew] ?? "0") + 1)
              .toString());
      setIsLoading(false);
      return true;
    }
    setIsLoading(false);
    return false;
  }

  Future<bool> updateTask({
    required String token,
    required String taskId,
    required String taskStatus,
    required String currentScreenStatus,
    required int index,
    required DashboardViewModel dashboardViewModel,
  }) async {
    setIsLoading(true);
    selectedIndex[currentScreenStatus] = index;
    response = await taskService.updateTask(token, taskId, taskStatus);
    if (response is Success) {
      List<TaskData>? tempData = _taskDataByStatus[currentScreenStatus]
          ?.where((taskData) => taskData.sId == taskId)
          .toList();
      if (tempData != null) {
        tempData[0].status = taskStatus;
        _taskDataByStatus[currentScreenStatus]!
            .removeWhere((taskData) => taskData.sId == taskId);
        _taskDataByStatus[taskStatus]?.add(tempData[0]);
        _taskDataByStatus[taskStatus]!.reversed.toList();
        selectedIndex[currentScreenStatus] = -1;
        int currentStatusCount =
            int.tryParse(taskStatusCount[currentScreenStatus]!) ?? 0;
        int targetStatusCount =
            int.tryParse(taskStatusCount[taskStatus].toString()) ?? 0;
        if (currentStatusCount != 0) {
          taskStatusCount[currentScreenStatus] =
              (currentStatusCount - 1).toString();
        }
        taskStatusCount[taskStatus] = (targetStatusCount + 1).toString();
      }
      _badgeCount[taskStatus] = (_badgeCount[taskStatus]! + 1);
      dashboardViewModel.refreshViewModel();
      setIsLoading(false);
      return true;
    }
    selectedIndex[currentScreenStatus] = -1;
    setIsLoading(false);
    return false;
  }

  void removeBadgeCount(int index, DashboardViewModel dashboardViewModel) {
    Map<int, String> taskIndex = {
      0: AppStrings.taskStatusNew,
      1: AppStrings.taskStatusProgress,
      2: AppStrings.taskStatusCompleted,
      3: AppStrings.taskStatusCanceled
    }; //it's placement is sync with index value of bottomNavBar
    _badgeCount[taskIndex[index]!] = 0;
    dashboardViewModel.refreshViewModel();
  }

  Future<bool> deleteTask(
      String token, String taskId, String taskStatus, int index) async {
    selectedIndex[taskStatus] = index;
    update();
    response = await taskService.deleteTask(taskId, token);
    if (response is Success) {
      _taskDataByStatus[taskStatus]
          ?.removeWhere((taskData) => taskData.sId == taskId);
      selectedIndex[taskStatus] = -1;
      taskStatusCount[taskStatus] =
          (int.parse(taskStatusCount[taskStatus].toString()) - 1).toString();
      update();
      return true;
    } else {
      selectedIndex[taskStatus] = -1;
      update();
      return false;
    }
  }

  void refreshViewModel() {
    update();
  }
}
