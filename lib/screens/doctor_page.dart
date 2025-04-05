import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPage extends StatefulWidget {
  final User user;

  const DoctorPage({Key? key, required this.user}) : super(key: key);

  @override
  _DoctorPageState createState() => _DoctorPageState();
}


class _DoctorPageState extends State<DoctorPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color.fromARGB(255, 252, 166, 45)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "All Patients",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
                _buildTextField(searchController, 'Search by ID or Name', Icons.search, false),
                const SizedBox(height: 20),

                // Patient List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('patients').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      var patients = snapshot.data!.docs;

                      var filteredPatients = patients.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String id = data['id'].toString().toLowerCase();
                        String name = data['name'].toString().toLowerCase();
                        return id.contains(_searchQuery) || name.contains(_searchQuery);
                      }).toList();

                      if (filteredPatients.isEmpty) {
                        return const Center(
                          child: Text(
                            'No patients found.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          var patient = filteredPatients[index].data() as Map<String, dynamic>;
                          String patientId = patient['id'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                patient['name'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("ID: ${patient['id']}"),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsPage(patientId: patientId),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon,
    bool isPassword,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }
}
