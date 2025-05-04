import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/search_bar.dart';
import 'search_results_screen.dart';

class FeaturedProductsScreen extends StatefulWidget {
  const FeaturedProductsScreen({Key? key}) : super(key: key);

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

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
        title: const Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomSearchBar(
                controller: _searchController,
                onSearch: _search,
              ),
            ),
            
            // Featured Products Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured Products',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 16),
            
            // Featured Products Grid
            Expanded(
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productProvider.featuredProducts.isEmpty
                      ? const Center(
                          child: Text('No featured products available'),
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
                          itemCount: productProvider.featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                productProvider.featuredProducts[index];
                            return ProductCard(product: product);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}