import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../components/custom_categories.dart';

class EditCategoryService {
  final BuildContext context;
  final CustomCategories customCategories;
  final Function onCategoryUpdated;

  EditCategoryService({
    required this.context,
    required this.customCategories,
    required this.onCategoryUpdated,
  });

  void showEditCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Categories'),
              content: FutureBuilder<List<String>>(
                future: customCategories.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data ?? [];
                  return SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        return ListTile(
                          title: Text(category),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  Color categoryColor = await customCategories.getCategoryColor(category) ?? Colors.grey;
                                  _showEditCategoryDialogDetail(category, categoryColor);
                                },
                              ),
                              IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool? confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this category?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmed == true) {
                                      await customCategories.deleteCategory(category);
                                      onCategoryUpdated();
                                      _showSnackBar('Category deleted successfully');
                                      setState(() {});
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),

                // TextButton(
                //   onPressed: () => Navigator.of(context).pop(),
                //   style: TextButton.styleFrom(
                //     foregroundColor: Theme.of(context).primaryColor, // Teks berwarna sesuai primaryColor tema
                //   ),
                //   child: const Text('Cancel'),
                // ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialogDetail(String category, Color initialColor) {
    TextEditingController _editCategoryController = TextEditingController(text: category);
    Color _tempSelectedColor = initialColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _editCategoryController,
                    decoration: const InputDecoration(
                      hintText: 'Edit category name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Select Color', style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Pick a color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: _tempSelectedColor,
                                onColorChanged: (color) {
                                  setState(() => _tempSelectedColor = color);
                                },
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Select'),
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
                      color: _tempSelectedColor,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_editCategoryController.text.trim().isNotEmpty) {
                      await customCategories.updateCategory(
                        category,
                        _editCategoryController.text,
                        _tempSelectedColor,
                      );
                      onCategoryUpdated();
                      Navigator.of(context).pop();
                      _showSnackBar('Category updated successfully');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
