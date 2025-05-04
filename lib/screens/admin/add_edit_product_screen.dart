import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = '';
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    
    // If editing a product, populate form fields
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _discountPriceController.text = widget.product!.discountPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.category;
      _isFeatured = widget.product!.isFeatured;
      if (widget.product!.images.isNotEmpty) {
        _imageUrlController.text = widget.product!.images[0];
      }
    }
    
    // Fetch categories if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Prepare product data
      List<String> images = [];
      if (_imageUrlController.text.trim().isNotEmpty) {
        images.add(_imageUrlController.text.trim());
      }
      
      if (widget.product != null) {
        // Update existing product
        ProductModel updatedProduct = widget.product!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          discountPrice: double.parse(_discountPriceController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          category: _selectedCategory,
          isFeatured: _isFeatured,
          images: images.isNotEmpty ? images : widget.product!.images,
        );
        
        bool success = await productProvider.updateProduct(updatedProduct);
        
        if (success && mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
            ),
          );
        }
      } else {
        // Create new product
        ProductModel newProduct = ProductModel(
          id: '', // Will be set by the service
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          discountPrice: double.parse(_discountPriceController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          category: _selectedCategory,
          isFeatured: _isFeatured,
          images: images,
          createdAt: DateTime.now(),
        );
        
        bool success = await productProvider.addProduct(newProduct);
        
        if (success && mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Preview
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _imageUrlController.text.isNotEmpty
                              ? Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : widget.product != null &&
                                      widget.product!.images.isNotEmpty
                                  ? Image.network(
                                      widget.product!.images[0],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Image URL Field
                    CustomTextField(
                      controller: _imageUrlController,
                      hintText: 'Image URL',
                      prefixIcon: Icons.image,
                      validator: (value) {
                        // Image URL is optional
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Product Name',
                      prefixIcon: Icons.shopping_bag,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Field
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Product Description',
                      prefixIcon: Icons.description,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Price Fields
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _priceController,
                            hintText: 'Price',
                            prefixIcon: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _discountPriceController,
                            hintText: 'Discount Price (Optional)',
                            prefixIcon: Icons.discount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stock Field
                    CustomTextField(
                      controller: _stockController,
                      hintText: 'Stock Quantity',
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select Category',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                      items: productProvider.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Featured Checkbox
                    CheckboxListTile(
                      title: const Text('Featured Product'),
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    
                    // Error Message
                    if (productProvider.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          productProvider.error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: widget.product != null ? 'Update Product' : 'Add Product',
                        isLoading: productProvider.isLoading,
                        onPressed: _saveProduct,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}