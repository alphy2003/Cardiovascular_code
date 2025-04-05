import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'patient_model.dart';
import 'package:cardiovascular_web/widgets/custom_text_field.dart';

class EditPatientPage extends StatefulWidget {
  final Patient patient;

  const EditPatientPage({Key? key, required this.patient}) : super(key: key);

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.patient.name);
    ageController = TextEditingController(text: widget.patient.age.toString());
  }

  void _updatePatient() async {
    final String name = nameController.text.trim();
    final int? age = int.tryParse(ageController.text.trim());

    if (name.isNotEmpty && age != null && age > 0) {
      final updatedPatient = Patient(id: widget.patient.id, name: name, age: age);

      try {
        await firestoreService.updatePatient(updatedPatient);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _deletePatient() async {
    try {
      await firestoreService.deletePatient(widget.patient.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Patient"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomTextField(controller: nameController, label: 'Name', icon: Icons.person),
            CustomTextField(controller: ageController, label: 'Age', icon: Icons.cake, isNumber: true),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _updatePatient, child: Text("Update")),
                ElevatedButton(onPressed: _deletePatient, child: Text("Delete"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
