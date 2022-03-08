import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smartdingdong/models/call_model.dart';
import 'package:smartdingdong/models/history_item_model.dart';
import 'package:smartdingdong/models/house_model.dart';
import 'package:smartdingdong/services/firestore_path.dart';
import 'package:smartdingdong/services/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in Firestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.
Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllTodoComplete is require to change all todos item to have the complete status
changed to true.
 */
class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _firestore = FirebaseFirestore.instance;
  final _firestoreService = FirestoreService.instance;

  // Method to retrieve all todos item from the same user based on uid
  Stream<List<HouseModel>> todosStream() => _firestoreService.collectionStream(
        path: FirestorePath.houses(uid),
        queryBuilder: (builder) {
          return builder.where(
            'owner',
            isEqualTo: _firestore.collection('accounts').doc(uid),
          );
        },
        builder: (data, documentId) => HouseModel.fromMap(data, documentId),
      );

  Future<void> updateHouseName(HouseModel house, String name) async {
    await house.reference.update({'name': name});
  }

  Stream<List<HistoryItemModel>> historyStream(String houseId) {
    print(houseId);
    var path = 'houses/' + (houseId == null ? '_' : houseId) + '/history';
    print(path);
    return _firestoreService.collectionStream(
      path: path,
      builder: (data, documentId) {
        return HistoryItemModel.fromMap(
          data,
          documentId,
        );
      },
    );
  }

  Future<Map<String, dynamic>> getUser(DocumentReference reference) async {
    try {
      final result = await reference.get();
      if (result.exists) {
        return Future.value(result.data());
      }
    } catch (error) {
      print(error);
    }
    Future.value(null);
  }

  Future<CallModel> makeCallToHouse({String id}) async {
    try {
      var result = await _firestore.collection('houses').doc(id).get();
      if (result.exists && result.data()['owner'] != null) {
        DocumentReference ownerReference = result.data()['owner'];
        DocumentReference myReference =
            _firestore.collection('accounts').doc(uid);

        final incomingUser = await getUser(ownerReference);

        print('incomingUser: $incomingUser');

        final historyItemReference =
            await result.reference.collection('history').add({
          'createdAt': Timestamp.now(),
          'status': 0,
          'visitorReference': myReference,
        });

        Map<String, dynamic> objectBody = {
          'createdAt': Timestamp.now(),
          'incoming': ownerReference,
          'outgoing': myReference,
          'users': [
            ownerReference,
            myReference,
          ],
          'targetHouse': result.reference,
          'historyItemReference': historyItemReference,
        };

        final callReference =
            await _firestore.collection('calls').add(objectBody);

        objectBody = {
          ...objectBody,
          'incomingUser': incomingUser,
        };

        CallModel callObject = CallModel.fromMap(
          objectBody,
          callReference,
        );
        print('CallObject: $callObject');

        return Future.value(callObject);
      } else {
        return Future.value(null);
      }
    } catch (error) {
      print(error);
      return Future.value(null);
    }
  }

  Future<DocumentReference> createCallHistoryItem(
      DocumentReference houseReference, Map<String, dynamic> data) async {
    try {
      DocumentReference myReference =
          _firestore.collection('accounts').doc(uid);
      final result = await houseReference.collection('history').add({
        'createdAt': Timestamp.now(),
        'visitorReference': myReference,
        ...data
      });
      print('createCallHistoryItem: $result');
      throw result;
    } catch (error) {
      throw error;
    }
  }

  Stream<List<HistoryItemModel>> historyTeste(String houseId) async* {
    final historyStream = _firestore
        .collection('houses')
        .doc(houseId)
        .collection('history')
        .snapshots();
    var historyList = List<HistoryItemModel>();
    await for (var historySnapshot in historyStream) {
      for (var itemDoc in historySnapshot.docs) {
        final index = historyList.indexWhere((item) => item.id == itemDoc.id);
        print(index);
        if (index != -1) {
          if (historyList[index].visitorReference != null) {
            final userSnapshot =
                await historyList[index].visitorReference.get();
            historyList[index].incomingUser =
                userSnapshot.data()['name'] != null
                    ? userSnapshot.data()['name']
                    : userSnapshot.data()['email'];
          }
        } else {
          final historyItem =
              HistoryItemModel.fromMap(itemDoc.data(), itemDoc.id);
          if (historyItem.visitorReference != null) {
            final userSnapshot = await historyItem.visitorReference.get();
            historyItem.incomingUser = userSnapshot.data()['name'] != null
                ? userSnapshot.data()['name']
                : userSnapshot.data()['email'];
          }
          historyList.add(historyItem);
        }
      }
      yield historyList;
    }
  }

  //Method to create/update todoModel
  // Future<void> setTodo(TodoModel todo) async => await _firestoreService.setData(
  //       path: FirestorePath.todo(uid, todo.id),
  //       data: todo.toMap(),
  //     );

  //Method to delete todoModel entry
  // Future<void> deleteTodo(TodoModel todo) async {
  //   await _firestoreService.deleteData(path: FirestorePath.todo(uid, todo.id));
  // }

  //Method to retrieve todoModel object based on the given todoId
  // Stream<TodoModel> todoStream({@required String todoId}) =>
  //     _firestoreService.documentStream(
  //       path: FirestorePath.todo(uid, todoId),
  //       builder: (data, documentId) => TodoModel.fromMap(data, documentId),
  //     );

  //Method to retrieve all todos item from the same user based on uid
  // Stream<List<TodoModel>> todosStream() => _firestoreService.collectionStream(
  //       path: FirestorePath.todos(uid),
  //       builder: (data, documentId) => TodoModel.fromMap(data, documentId),
  //     );

  //Method to mark all todoModel to be complete
  // Future<void> setAllTodoComplete() async {
  //   final batchUpdate = Firestore.instance.batch();

  //   final querySnapshot = await Firestore.instance
  //       .collection(FirestorePath.todos(uid))
  //       .getDocuments();

  //   for (DocumentSnapshot ds in querySnapshot.documents) {
  //     batchUpdate.updateData(ds.reference, {'complete': true});
  //   }
  //   await batchUpdate.commit();
  // }

  // Future<void> deleteAllTodoWithComplete() async {
  //   final batchDelete = Firestore.instance.batch();

  //   final querySnapshot = await Firestore.instance
  //       .collection(FirestorePath.todos(uid))
  //       .where('complete', isEqualTo: true)
  //       .getDocuments();

  //   for (DocumentSnapshot ds in querySnapshot.documents) {
  //     batchDelete.delete(ds.reference);
  //   }
  //   await batchDelete.commit();
  // }
}
