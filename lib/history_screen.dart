import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final String childUID;
  final String childName;
  const HistoryScreen({super.key, required this.childUID, required this.childName});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("$childName's Activity"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.route), text: "Pattern"),
              Tab(icon: Icon(Icons.list_alt), text: "Textual"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPatternSummary(),
            _buildTextualLog(),
          ],
        ),
      ),
    );
  }

  // 1. Pattern Summary: Visual representation of movement
  Widget _buildPatternSummary() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Movement Pattern (Last 24h)", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(childUID).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var data = snapshot.data!.data() as Map<String, dynamic>?;
              double lat = data?['last_lat'] ?? 0.0;
              double lng = data?['last_lng'] ?? 0.0;
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gesture, size: 80, color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    Text("Current Node: $lat, $lng"),
                    const Text("Pattern flow analysis active.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. Textual Log: Time-stamped history of locations
  Widget _buildTextualLog() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(childUID).collection('location_history').doc(today).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No textual logs found for today."));
        }
        
        var data = snapshot.data!.data() as Map<String, dynamic>;
        List path = data['path'] ?? [];

        return ListView.builder(
          itemCount: path.length,
          itemBuilder: (context, index) {
            var point = path[index];
            return ListTile(
              leading: const Icon(Icons.location_history, color: Colors.indigo),
              title: Text("Checkpoint ${index + 1}"),
              subtitle: Text("Lat: ${point['lat']}, Lng: ${point['lng']}"),
              trailing: Text(point['time'] ?? "--:--", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            );
          },
        );
      },
    );
  }
}