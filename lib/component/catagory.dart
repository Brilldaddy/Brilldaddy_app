import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _categoryService = ApiService();
  List<dynamic> _categories = [];
  String? _currentParentId;

  List<dynamic> get categories => _categories;
  String? get currentParentId => _currentParentId;

  Future<void> loadCategories() async {
    try {
      _categories = await _categoryService.fetchCategories();
      notifyListeners();
    } catch (e) {
      print("Error: $e");
    }
  }

  void setCurrentParentId(String? parentId) {
    _currentParentId = parentId;
    notifyListeners();
  }

  List<dynamic> getDisplayedCategories() {
    return _categories.where((category) {
      return (_currentParentId == null && category['parentCategory'] == null) ||
          category['parentCategory'] == _currentParentId;
    }).toList();
  }
}

class NavbarWithMenu extends StatelessWidget implements PreferredSizeWidget {
  const NavbarWithMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Navbar"),
      backgroundColor: Colors.blue[900],
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _showCategoriesDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamed(context, '/'),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/event'),
          child: const Text("Events",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  void _showCategoriesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final categoryProvider = Provider.of<CategoryProvider>(context);
        final displayedCategories = categoryProvider.getDisplayedCategories();

        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categoryProvider.currentParentId != null)
                TextButton(
                  onPressed: () => categoryProvider.setCurrentParentId(null),
                  child: const Text("← Back",
                      style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              Expanded(
                child: ListView(
                  children: displayedCategories.map((category) {
                    return ListTile(
                      title: Text(category['name']),
                      onTap: () {
                        bool hasSubcategories = categoryProvider.categories
                            .any((c) => c['parentCategory'] == category['_id']);
                        if (hasSubcategories) {
                          categoryProvider.setCurrentParentId(category['_id']);
                        } else {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/shopCategory',
                              arguments: {"category": category['name']});
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
