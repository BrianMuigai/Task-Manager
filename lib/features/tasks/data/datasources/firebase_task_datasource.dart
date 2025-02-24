import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/task_model.dart';

@lazySingleton
class FirebaseTaskDataSource {
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<List<TaskModel>> getTasks() async {
    final snapshot =
        await tasksCollection.orderBy('updatedAt', descending: true).get();
    return snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList();
  }

  // Real-time stream for task syncing and collaboration.
  Stream<List<TaskModel>> tasksStream() {
    return tasksCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Future<void> addTask(TaskModel task) async {
    await tasksCollection.add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await tasksCollection.doc(id).delete();
  }
}
