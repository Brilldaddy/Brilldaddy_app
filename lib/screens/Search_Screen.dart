import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'shop.dart';

class SearchComponent extends StatefulWidget {
  final String serverUrl;
  final Function(String) onSearch;

  const SearchComponent({
    Key? key,
    required this.serverUrl,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SearchComponent> createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _productNames = [];
  List<String> _filteredSuggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Listen for changes in the search field
    _searchController.addListener(_handleSearchChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products from the server
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('${widget.serverUrl}/user/products'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            _productNames = data
                .map<String>((product) => product['name'].toString())
                .toList();
          });
        } else {
          setState(() {
            _productNames = [];
          });
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching product names: $error');
      setState(() {
        _productNames = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter suggestions based on search term
  void _handleSearchChange() {
    final value = _searchController.text;

    if (value.isNotEmpty) {
      final filtered = _productNames
          .where((name) => name.toLowerCase().contains(value.toLowerCase()))
          .toList();

      setState(() {
        _filteredSuggestions = filtered;
        _showSuggestions = true;
      });
    } else {
      setState(() {
        _filteredSuggestions = [];
        _showSuggestions = false;
      });
    }
  }

  // Handle search submission
  void _handleSearchSubmit() {
    widget.onSearch(_searchController.text);
    setState(() {
      _showSuggestions = false;
    });
    FocusScope.of(context).unfocus();
  }

  // Handle suggestion selection
  void _handleSuggestionSelect(String suggestion) {
    _searchController.text = suggestion;
    widget.onSearch(suggestion);
    setState(() {
      _showSuggestions = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              // Search icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: FaIcon(
                  FontAwesomeIcons.search,
                  color: Colors.grey.shade500,
                  size: 16,
                ),
              ),
              // Search input field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onSubmitted: (_) => _handleSearchSubmit(),
                ),
              ),
              // Clear button (shows only when there's text)
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                ),
            ],
          ),
        ),
        // Suggestions list
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredSuggestions[index]),
                  onTap: () =>
                      _handleSuggestionSelect(_filteredSuggestions[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Example usage in a parent widget:
class SearchScreen extends StatelessWidget {
  final String serverUrl = 'https://api.brilldaddy.com/api';

  const SearchScreen({Key? key}) : super(key: key);

  void _onSearch(BuildContext context, String query) {
    // Navigate to search results page
    // For example:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopPage(),
      ),
    );

    print('Searching for: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SearchComponent(
        serverUrl: serverUrl,
        onSearch: (query) => _onSearch(context, query),
      ),
    );
  }
}
