import 'package:finance_tracker/components/custom_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_tracker/components/custom_button.dart';
import 'package:finance_tracker/components/custom_categories.dart';
import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:finance_tracker/services/edit_category.dart';
class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  _AddExpensesScreenState createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  String? _selectedType;
  DateTime? _selectedDate;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final CustomCategories _customCategories = CustomCategories();
  List<String> _categories = [];
  Color _selectedColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _addNewCategory(String category, Color color) async {
    if (category.trim().isEmpty) return;

    try {
      await _customCategories.addNewCategory(category, color);
      setState(() {
        categoryColors[category] = color;
      });
      await _loadCategories();
      _showSnackBar('Successfully created new category');
    } catch (e) {
      _showSnackBar('Failed to create new category', isError: true);
    }
  }

  String _formatCurrency(String value) {
    final unformattedValue = value.replaceAll(RegExp(r'[Rp.,]'), '');
    final amount = double.tryParse(unformattedValue) ?? 0;
    return CurrencyFormatter.formatCurrency(amount);
  }

  Future<void> _loadCategories() async {
    _categories = await _customCategories.getCategories();
    for (var category in _categories) {
      categoryColors[category] = await _customCategories.getCategoryColor(category) ?? Colors.grey;
    }
    setState(() {});
  }

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

  void _resetFields() {
    setState(() {
      _selectedType = null;
      _selectedDate = null;
      _priceController.clear();
      _nameController.clear();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? Colors.red.withOpacity(0.9) : Colors.green.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(
          bottom: 20,
          right: 20,
          left: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'Add New Expenses',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController _newTypeController = TextEditingController();
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    backgroundColor: theme.cardColor,
                                    title: Text('Create New Category', 
                                      style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _newTypeController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter new category',
                                            hintStyle: TextStyle(
                                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                              fontSize: 16,
                                            ),
                                          ),
                                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                        ),
                                        const SizedBox(height: 16),
                                        Text('Select Color', 
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: theme.textTheme.bodyLarge?.color
                                          )
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: theme.cardColor,
                                                  title: Text('Pick a color', 
                                                    style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                                                  content: SingleChildScrollView(
                                                    child: ColorPicker(
                                                      pickerColor: _selectedColor,
                                                      onColorChanged: (color) {
                                                        setState(() => _selectedColor = color);
                                                      },
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Select', 
                                                        style: TextStyle(color: theme.primaryColor)),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: 100,
                                            height: 30,
                                            color: _selectedColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('Cancel', 
                                          style: TextStyle(color: theme.primaryColor)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (_newTypeController.text.isNotEmpty) {
                                            await _addNewCategory(_newTypeController.text, _selectedColor);
                                            _newTypeController.clear();
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text('Add', 
                                          style: TextStyle(color: theme.primaryColor)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Text(
                          'Create New Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          EditCategoryService(
                            context: context,
                            customCategories: _customCategories,
                            onCategoryUpdated: _loadCategories,
                          ).showEditCategoryDialog();
                        },
                        child: Text(
                          'Edit Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: IconButton(
                      icon: Icon(Icons.close, 
                        color: theme.iconTheme.color),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: theme.primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: theme.primaryColor),
                          ),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        ),
                        hint: Text('Select Category', 
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5))),
                        dropdownColor: theme.cardColor,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        },
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Name',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: 'Input Name',
                        hintStyle: TextStyle(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Price',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: 'Input Price',
                        hintStyle: TextStyle(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      onChanged: (value) {
                        final formattedValue = _formatCurrency(value);
                        _priceController.value = TextEditingValue(
                          text: formattedValue,
                          selection: TextSelection.collapsed(offset: formattedValue.length),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Date',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: _selectedDate != null
                                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : 'Select Date',
                            hintStyle: TextStyle(
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            suffixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: theme.primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: theme.primaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: CustomButton(
                        text: 'Create',
                        onPressed: () async {
                          if (_selectedType == null || 
                              _nameController.text.isEmpty ||
                              _priceController.text.isEmpty ||
                              _selectedDate == null) {
                            _showSnackBar('Please fill all fields', isError: true);
                            return;
                          }

                          try {
                            double price = double.parse(_priceController.text.replaceAll(RegExp(r'[^\d]'), ''));
                            await _customCategories.addExpense(
                              price,
                              _selectedType!,
                              _nameController.text,
                              _selectedDate!,
                            );
                            _showSnackBar('Success create new expenses');
                            _resetFields();
                          } catch (e) {
                            _showSnackBar('Failed to create expense', isError: true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}