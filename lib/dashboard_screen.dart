import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String pUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Guardian Hub"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut().then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()))))
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(pUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var children = snapshot.data!.get('linked_children') as List;

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(children[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showOptions(context, children[index]['id'], children[index]['name']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addChildDialog(context, pUid),
        label: const Text("Link Child"),
        icon: const Icon(Icons.link),
      ),
    );
  }

  void _showOptions(context, id, name) {
    showModalBottomSheet(context: context, builder: (c) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(leading: const Icon(Icons.map), title: const Text("Live Map"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MapScreen(childUID: id)))),
        ListTile(leading: const Icon(Icons.history), title: const Text("Activity Summary"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen(childUID: id, childName: name)))),
      ],
    ));
  }

  void _addChildDialog(context, pUid) {
    final idC = TextEditingController();
    final nameC = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Link Child Device"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: const InputDecoration(hintText: "Child Name")),
        TextField(controller: idC, decoration: const InputDecoration(hintText: "Child UID")),
      ]),
      actions: [ElevatedButton(onPressed: () async {
        await FirebaseFirestore.instance.collection('users').doc(pUid).update({
          'linked_children': FieldValue.arrayUnion([{'id': idC.text, 'name': nameC.text}])
        });
        Navigator.pop(context);
      }, child: const Text("Link"))],
    ));
  }
}