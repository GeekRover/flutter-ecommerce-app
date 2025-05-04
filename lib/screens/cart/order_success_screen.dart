import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Success Message
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your order #$orderId has been placed successfully. You will receive a confirmation email shortly.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Order ID
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Order ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Continue Shopping Button
                CustomButton(
                  text: 'Continue Shopping',
                  onPressed: () {
                    // Navigate back to home screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 16),
                
                // View Order Button
                OutlinedButton(
                  onPressed: () {
                    // Navigate to order details screen
                    // Implement navigation to order details screen here
                    Navigator.popUntil(context, (route) => route.isFirst);
                    
                    // To be implemented: Navigate to profile tab and then to order history
                    // For now, just navigate home
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  child: const Text('View Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}