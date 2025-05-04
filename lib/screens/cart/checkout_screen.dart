import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _selectedPaymentMethod = 'Cash on Delivery';
  final List<String> _paymentMethods = ['Cash on Delivery', 'Credit Card', 'PayPal'];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      String? orderId = await orderProvider.createOrder(
        _addressController.text.trim(),
        _selectedPaymentMethod,
      );
      
      if (orderId != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(orderId: orderId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shipping Information
                    const Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      hintText: 'Full Address',
                      prefixIcon: Icons.location_on,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your shipping address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _paymentMethods.map((method) {
                          return RadioListTile<String>(
                            title: Text(method),
                            value: method,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Order Summary
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', cartProvider.total),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Shipping', 10.0),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Tax (5%)', cartProvider.total * 0.05),
                          const Divider(),
                          _buildSummaryRow(
                            'Total',
                            cartProvider.total + 10.0 + (cartProvider.total * 0.05),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Error Message
                    if (orderProvider.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          orderProvider.error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Place Order',
                        isLoading: orderProvider.isLoading,
                        onPressed: _placeOrder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }
}