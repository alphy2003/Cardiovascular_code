import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // For SHA-256 hashing
import 'patient_model.dart';

class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  const PatientDetailsPage({required this.patientId, Key? key}) : super(key: key);

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController hrController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController respController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController hemoController = TextEditingController();
  final TextEditingController sodiumController = TextEditingController();
  final TextEditingController potassiumController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _imageUrls = []; // For images fetched from Firestore
  List<Uint8List> _pickedImages = []; // For newly uploaded images
  List<String> _imageNames = []; // For names of newly uploaded images
  String? _publicId;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    final patientDoc = await _firestore.collection('patients').doc(widget.patientId).get();
    if (patientDoc.exists) {
      Map<String, dynamic> patient = patientDoc.data() as Map<String, dynamic>;

      setState(() {
        idController.text = patient['id'] ?? '';
        nameController.text = patient['name'] ?? '';
        ageController.text = patient['age']?.toString() ?? '';
        hrController.text = patient['heartRate']?.toString() ?? '';
        bpController.text = patient['bloodPressure'] ?? '';
        spo2Controller.text = patient['oxygenSaturation']?.toString() ?? '';
        tempController.text = patient['temperature']?.toString() ?? '';
        respController.text = patient['respiratoryRate']?.toString() ?? '';
        glucoseController.text = patient['bloodGlucose']?.toString() ?? '';
        cholesterolController.text = patient['cholesterol']?.toString() ?? '';
        hemoController.text = patient['hemoglobin']?.toString() ?? '';
        var electrolytes = patient['electrolytes'] as Map<String, dynamic>?;
        sodiumController.text = electrolytes?['Sodium']?.toString() ?? '';
        potassiumController.text = electrolytes?['Potassium']?.toString() ?? '';

        // Fetch multiple image URLs
        _imageUrls = List<String>.from(patient['imageUrls'] ?? []);
      });
    } else {
      print("Patient document does not exist");
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _pickedImages.add(result.files.single.bytes!);
        _imageNames.add(result.files.single.name);
      });
    } else {
      print("No image selected");
    }
  }

  Future<void> _uploadImageToCloudinary(Uint8List imageBytes, String imageName) async {
    const String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dradg3yen/image/upload";
    const String uploadPreset = "medpulse";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imageName,
        ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        String imageUrl = jsonResponse["secure_url"];
        String publicId = jsonResponse["public_id"];

        setState(() {
          _imageUrls.add(imageUrl); // Add the new image URL to the list
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        print("Failed to upload image: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image!")),
      );
    }
  }

  Future<void> _deleteImageFromCloudinary(String imageUrl) async {
    // Find the public_id from the image URL (if needed)
    // For simplicity, assume the imageUrl contains the public_id
    String publicId = imageUrl.split('/').last.split('.').first;

    const String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dradg3yen/image/destroy";
    const String apiKey = "771362683939584"; // Replace with your Cloudinary API key
    const String apiSecret = "HRAQkLeOYmw1jM7-sGyvvkRlNY8"; // Replace with your Cloudinary API secret

    // Generate a timestamp
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Generate the signature
    String signatureString = "public_id=$publicId&timestamp=$timestamp$apiSecret";
    var bytes = utf8.encode(signatureString);
    var digest = sha256.convert(bytes);
    String signature = digest.toString();

    try {
      var response = await http.post(
        Uri.parse(cloudinaryUrl),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageUrls.remove(imageUrl); // Remove the image from the list
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image deleted successfully!")),
        );
      } else {
        print("Failed to delete image: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error deleting image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete image!")),
      );
    }
  }

  void _removePickedImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
      _imageNames.removeAt(index);
    });
  }

  Future<void> _savePatient() async {
    // Upload newly picked images to Cloudinary
    for (var i = 0; i < _pickedImages.length; i++) {
      await _uploadImageToCloudinary(_pickedImages[i], _imageNames[i]);
    }

    // Save the patient details
    Patient updatedPatient = Patient(
      id: idController.text.trim(),
      name: nameController.text.trim(),
      age: int.tryParse(ageController.text.trim()) ?? 0,
      heartRate: int.tryParse(hrController.text.trim()),
      bloodPressure: bpController.text.trim().isNotEmpty ? bpController.text.trim() : null,
      oxygenSaturation: int.tryParse(spo2Controller.text.trim()),
      temperature: double.tryParse(tempController.text.trim()),
      respiratoryRate: int.tryParse(respController.text.trim()),
      bloodGlucose: int.tryParse(glucoseController.text.trim()),
      cholesterol: int.tryParse(cholesterolController.text.trim()),
      hemoglobin: double.tryParse(hemoController.text.trim()),
      electrolytes: {
        "Sodium": double.tryParse(sodiumController.text.trim()) ?? 0.0,
        "Potassium": double.tryParse(potassiumController.text.trim()) ?? 0.0,
      },
      imageUrls: _imageUrls, // Use the updated _imageUrls list
    );

    await _firestore.collection('patients').doc(updatedPatient.id).set(updatedPatient.toJson());

    // Clear the picked images and their names after saving
    setState(() {
      _pickedImages.clear();
      _imageNames.clear();
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Patient updated successfully!")),
    );

    // Navigate back to the previous page
    Navigator.pop(context);
  }

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Patient Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Patient ID Field
                _buildTextField(idController, 'Patient ID', Icons.person, false, isReadOnly: true),
                const SizedBox(height: 16),

                // Name Field
                _buildTextField(nameController, 'Name', Icons.person_outline, false),
                const SizedBox(height: 16),

                // Age Field
                _buildTextField(ageController, 'Age', Icons.calendar_today, false),
                const SizedBox(height: 16),

                // Heart Rate Field
                _buildTextField(hrController, 'Heart Rate', Icons.favorite, false),
                const SizedBox(height: 16),

                // Blood Pressure Field
                _buildTextField(bpController, 'Blood Pressure', Icons.monitor_heart, false),
                const SizedBox(height: 16),

                // SpO2 Field
                _buildTextField(spo2Controller, 'SpO2', Icons.air, false),
                const SizedBox(height: 16),

                // Temperature Field
                _buildTextField(tempController, 'Temperature', Icons.thermostat, false),
                const SizedBox(height: 16),

                // Respiratory Rate Field
                _buildTextField(respController, 'Respiratory Rate', Icons.airline_seat_recline_normal, false),
                const SizedBox(height: 16),

                // Blood Glucose Field
                _buildTextField(glucoseController, 'Blood Glucose', Icons.bloodtype, false),
                const SizedBox(height: 16),

                // Cholesterol Field
                _buildTextField(cholesterolController, 'Cholesterol', Icons.health_and_safety, false),
                const SizedBox(height: 16),

                // Hemoglobin Field
                _buildTextField(hemoController, 'Hemoglobin', Icons.medical_services, false),
                const SizedBox(height: 16),

                // Sodium Field
                _buildTextField(sodiumController, 'Sodium', Icons.science, false),
                const SizedBox(height: 16),

                // Potassium Field
                _buildTextField(potassiumController, 'Potassium', Icons.science, false),
                const SizedBox(height: 20),

                // Image Display and Picker
                Column(
                  children: [
                    // Display fetched images (already in the database)
                    for (var imageUrl in _imageUrls)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Image.network(imageUrl, height: 100),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteImageFromCloudinary(imageUrl),
                          ),
                        ),
                      ),

                    // Display newly picked images (not yet uploaded)
                    for (var i = 0; i < _pickedImages.length; i++)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Image.memory(_pickedImages[i], height: 100),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removePickedImage(i),
                          ),
                        ),
                      ),

                    // Pick Image Button
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      ),
                      child: const Text('Pick Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Save Changes Button
                ElevatedButton(
                  onPressed: _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // **Reusable Widgets**
  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon, bool isPassword, {bool isReadOnly = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        readOnly: isReadOnly,
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
      ),
    );
  }
}