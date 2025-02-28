import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String sortBy = "default";
  List products = [];
  List categories = [];
  int currentPage = 1;
  int itemsPerPage = 40;
  Map<String, bool> wishlist = {};
  String selectedCategory = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.brilldaddy.com/api/user/products'));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body) ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Error fetching products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.brilldaddy.com/api/user/category'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body) ?? [];
        });
      } else {
        throw Exception('Error fetching categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void toggleWishlist(String productId) {
    setState(() {
      wishlist[productId] = !(wishlist[productId] ?? false);
    });
  }

  List getFilteredProducts() {
    return products.where((product) {
      String productName = product['name']?.toString() ?? '';
      String productCategory = product['category']?.toString() ?? '';

      return productName.toLowerCase().contains(searchQuery.toLowerCase()) &&
          (selectedCategory.isEmpty || productCategory == selectedCategory);
    }).toList();
  }

  List getSortedProducts(List filteredProducts) {
    switch (sortBy) {
      case 'az':
        filteredProducts.sort((a, b) => (a['name']?.toString() ?? '')
            .compareTo(b['name']?.toString() ?? ''));
        break;
      case 'za':
        filteredProducts.sort((a, b) => (b['name']?.toString() ?? '')
            .compareTo(a['name']?.toString() ?? ''));
        break;
      case 'priceasc':
        filteredProducts.sort(
            (a, b) => (a['salePrice'] ?? 0).compareTo(b['salePrice'] ?? 0));
        break;
      case 'pricedesc':
        filteredProducts.sort(
            (a, b) => (b['salePrice'] ?? 0).compareTo(a['salePrice'] ?? 0));
        break;
    }
    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    List filteredProducts = getSortedProducts(getFilteredProducts());
    List displayedProducts = filteredProducts
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();
    int totalPages = (filteredProducts.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: ProductSearchDelegate(products),
              );

              if (result != null) {
                setState(() {
                  searchQuery = result;
                });
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: sortBy,
                    onChanged: (newValue) {
                      setState(() {
                        sortBy = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'default', child: Text('Relevant')),
                      DropdownMenuItem(value: 'az', child: Text('A to Z')),
                      DropdownMenuItem(value: 'za', child: Text('Z to A')),
                      DropdownMenuItem(
                          value: 'priceasc', child: Text('Price: Low to High')),
                      DropdownMenuItem(
                          value: 'pricedesc',
                          child: Text('Price: High to Low')),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      var product = displayedProducts[index];
                      String productId = product['_id']?.toString() ?? '';
                      String productName =
                          product['name']?.toString() ?? 'No Name';
                      String productImage = product['imageUrl']?.toString() ??
                          'https://via.placeholder.com/150';
                      int productPrice = product['salePrice'] ?? 0;

                      return GestureDetector(
                        onTap: () {},
                        child: Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image);
                                  },
                                ),
                              ),
                              Text(productName),
                              Text('₹$productPrice'),
                              IconButton(
                                icon: Icon(
                                  wishlist[productId] == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: wishlist[productId] == true
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () => toggleWishlist(productId),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: currentPage > 1
                          ? () => setState(() => currentPage--)
                          : null,
                    ),
                    Text('$currentPage of $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages
                          ? () => setState(() => currentPage++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String?> {
  final List products;
  ProductSearchDelegate(this.products);

  @override
  Widget buildSuggestions(BuildContext context) {
    List filteredProducts = products
        .where((product) =>
            (product['name']?.toString() ?? '').toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredProducts[index]['name']?.toString() ?? 'Unknown'),
          onTap: () {
            close(context, filteredProducts[index]['name']?.toString()); // Return result
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => 
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
}
