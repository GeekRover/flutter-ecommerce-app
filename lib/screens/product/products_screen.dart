import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/search_bar.dart';
import 'search_results_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    if (_searchController.text.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SearchResultsScreen(query: _searchController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              onSearch: _search,
            ),
          ),
          
          // Categories
          SizedBox(
            height: 50,
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: productProvider.categories.length + 1, // +1 for "All" category
                    itemBuilder: (context, index) {
                      // All category
                      if (index == 0) {
                        return _buildCategoryItem(
                          'All',
                          productProvider.selectedCategory.isEmpty,
                          () => productProvider.selectCategory(''),
                        );
                      }
                      
                      // Other categories
                      final category = productProvider.categories[index - 1];
                      return _buildCategoryItem(
                        category,
                        productProvider.selectedCategory == category,
                        () => productProvider.selectCategory(category),
                      );
                    },
                  ),
          ),
          
          // Products Grid
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(
                        child: Text('No products available'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          return ProductCard(product: product);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      String name, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          foregroundColor:
              isSelected ? Colors.white : Theme.of(context).primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(name),
      ),
    );
  }
}