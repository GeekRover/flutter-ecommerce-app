import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Order Filters
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search orders...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            // Implement search functionality
                            // This basic version doesn't include real-time search
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.filter_list),
                        onSelected: (value) {
                          // Implement filter functionality
                          // This basic version doesn't include filtering
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'all',
                            child: Text('All Orders'),
                          ),
                          const PopupMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          const PopupMenuItem(
                            value: 'processing',
                            child: Text('Processing'),
                          ),
                          const PopupMenuItem(
                            value: 'shipped',
                            child: Text('Shipped'),
                          ),
                          const PopupMenuItem(
                            value: 'delivered',
                            child: Text('Delivered'),
                          ),
                          const PopupMenuItem(
                            value: 'cancelled',
                            child: Text('Cancelled'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Orders List
                Expanded(
                  child: orderProvider.orders.isEmpty
                      ? const Center(
                          child: Text('No orders found'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orderProvider.orders.length,
                          itemBuilder: (context, index) {
                            final order = orderProvider.orders[index];
                            return _buildOrderItem(context, order, orderProvider);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Customer Info
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Customer ID: ${order.userId}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Order Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Order Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminOrderDetailsScreen(
                                orderId: order.id,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View Details'),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusUpdateButton(context, order, orderProvider),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusUpdateButton(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
  ) {
    // Don't show status update for delivered or cancelled orders
    if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    // Determine next status
    OrderStatus nextStatus;
    switch (order.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.processing;
        break;
      case OrderStatus.processing:
        nextStatus = OrderStatus.shipped;
        break;
      case OrderStatus.shipped:
        nextStatus = OrderStatus.delivered;
        break;
      default:
        return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Order Status'),
            content: Text(
                'Are you sure you want to update the status to "${_getStatusText(nextStatus)}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  bool success = await orderProvider.updateOrderStatus(
                    order.id,
                    nextStatus,
                  );
                  
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order status updated successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Mark as ${_getStatusText(nextStatus)}',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}