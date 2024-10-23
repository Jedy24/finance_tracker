import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExpensesScreen extends StatefulWidget {
  @override
  _AddExpensesScreenState createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  String? _selectedType; // Dropdown value
  DateTime? _selectedDate; // DatePicker value
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Function to show DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        'Add New Expenses',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Tambahkan button "Create New Type" disini
                      TextButton(
                        onPressed: () {
                          // Logika untuk menambahkan tipe baru
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController _newTypeController =
                                  TextEditingController();
                              return AlertDialog(
                                title: const Text('Create New Type'),
                                content: TextField(
                                  controller: _newTypeController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter new type',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Tambahkan tipe baru ke dropdown dan tutup dialog
                                      setState(() {
                                        if (_newTypeController
                                            .text.isNotEmpty) {
                                          // Update logic here to manage dynamic types
                                        }
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          'Create New Type',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for "Type"
                  Text(
                    'Type',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                    ),
                    hint: const Text('Select Type'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    items: <String>['Food', 'Transport', 'Entertainment', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Input for "Name"
                  Text(
                    'Name',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Input Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input for "Price"
                  Text(
                    'Price',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Input Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DatePicker for "Date"
                  Text(
                    'Date',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: _selectedDate != null
                              ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                              : 'Select Date',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button "Create"
                  Center(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF12B0F8), Color(0xFF007AFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic untuk mengirim data atau menyimpan expenses
                          // Tambahkan logika di sini
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Make background transparent
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
