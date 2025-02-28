import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category_models.dart';
import '../../models/product.dart';
import '../../screens/shop_category_page.dart';
import '../../services/CategoryService.dart' show CategoryService;
import '../../widgets/category_card.dart';

class CategoryScroller extends StatefulWidget {
  const CategoryScroller({Key? key}) : super(key: key);

  @override
  State<CategoryScroller> createState() => _CategoryScrollerState();
}

class _CategoryScrollerState extends State<CategoryScroller> {
  bool isLoading = true;

  List<Category> categories = [];

  String errorMessage = '';

  String? authToken;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('authToken');
      if (authToken == null || authToken!.isEmpty) {
        setState(() {
          errorMessage = "User not authenticated.";
          isLoading = false;
        });
        return;
      }
      final fetchedCategories = await CategoryService.fetchCategories(authToken!);
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching categories: $e";
        isLoading = false;
      });
    }
  }

  void handleCategoryClick(Category category) {
    // Navigate to ShopCategoryPage with the selected category's name.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopCategoryPage(category: category.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shop by Category",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryCard(
                  title: "Stationary",
                  imageUrl:
                      "https://media.istockphoto.com/id/485725200/photo/school-and-office-accessories-on-wooden-background.jpg?s=612x612&w=0&k=20&c=PWgiIA-7_QDC_PXnEhwZqDLDDzrNMIxxJjBeD4h4oLM=",
                  description: "All Stationary items under this",
                  onClick: () => handleCategoryClick(Category(
                    id: '1',
                    name: "Stationary",
                    description: "All Stationary items under this",
                    product: Product(
                      id: '1',
                      name: 'Stationary Products',
                      description: 'All Stationary items under this',
                      productPrice: 10.0,
                      salePrice: 8.0,
                      category: 'Stationary',
                      brand: 'Brand A',
                      isListed: true,
                      quantity: 100,
                      discount: 0.1,
                      color: 'Blue',
                      imageIds: ['image1', 'image2'],
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      averageRating: 4.5,
                    ),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  )),
                ),
                CategoryCard(
                  title: "Electronics and Home Appliances",
                  imageUrl:
                      "https://assets.architecturaldigest.in/photos/60084fc951daf9662c149bb9/16:9/w_2560%2Cc_limit/how-to-clean-gadgets-1366x768.jpg",
                  description:
                      "Latest gadgets and devices at unbeatable prices.",
                  onClick: () => handleCategoryClick(Category(
                    id: '2',
                    name: "Electronics and Home Appliances",
                    description: "Latest gadgets and devices at unbeatable prices.",
                    product: Product(
                      id: '2',
                      name: 'Electronics Products',
                      description: 'Latest gadgets and devices at unbeatable prices.',
                      productPrice: 100.0,
                      salePrice: 90.0,
                      category: 'Electronics',
                      brand: 'Brand B',
                      isListed: true,
                      quantity: 50,
                      discount: 0.1,
                      color: 'Black',
                      imageIds: ['image3', 'image4'],
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      averageRating: 4.8,
                    ),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  )),
                ),
                CategoryCard(
                  title: "Jewellery",
                  imageUrl:
                      "https://d25xd2afqp2r8a.cloudfront.net/blog/14f491d8-2176-40a2-85fd-5c97cfa81c42.jpg",
                  description: "High-quality jewellery for all occasions.",
                  onClick: () => handleCategoryClick(Category(
                    id: '3',
                    name: "Jewellery",
                    description: "High-quality jewellery for all occasions.",
                    product: Product(
                      id: '3',
                      name: 'Jewellery Products',
                      description: 'High-quality jewellery for all occasions.',
                      productPrice: 200.0,
                      salePrice: 180.0,
                      category: 'Jewellery',
                      brand: 'Brand C',
                      isListed: true,
                      quantity: 30,
                      discount: 0.15,
                      color: 'Gold',
                      imageIds: ['image5', 'image6'],
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      averageRating: 4.7,
                    ),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  )),
                ),
                CategoryCard(
                  title: "Decor and Dine",
                  imageUrl:
                      "https://images.pexels.com/photos/1099816/pexels-photo-1099816.jpeg",
                  description: "Stylish decor and dining essentials.",
                  onClick: () => handleCategoryClick(Category(
                    id: '4',
                    name: "Decor and Dine",
                    description: "Stylish decor and dining essentials.",
                    product: Product(
                      id: '4',
                      name: 'Decor and Dine Products',
                      description: 'Stylish decor and dining essentials.',
                      productPrice: 50.0,
                      salePrice: 45.0,
                      category: 'Decor',
                      brand: 'Brand D',
                      isListed: true,
                      quantity: 70,
                      discount: 0.05,
                      color: 'White',
                      imageIds: ['image7', 'image8'],
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      averageRating: 4.6,
                    ),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
