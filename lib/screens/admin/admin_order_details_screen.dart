import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .selectOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (orderProvider.selectedOrder != null) {
                _showActionsMenu(context, orderProvider.selectedOrder!);
              }
            },
          ),
        ],
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.selectedOrder == null
              ? const Center(child: Text('Order not found'))
              : _buildOrderDetails(context, orderProvider.selectedOrder!),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(context, order),
                  const SizedBox(height: 16),
                  _buildStatusUpdateButtons(context, order),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Order Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Order ID', order.id),
                  _buildInfoRow('Date', _formatDate(order.createdAt)),
                  _buildInfoRow('Customer ID', order.userId),
                  _buildInfoRow('Payment Method', order.paymentMethod),
                  _buildInfoRow('Shipping Address', order.shippingAddress),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Order Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...order.items.map((item) => _buildOrderItem(context, item)).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Order Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Subtotal', order.subtotal),
                  _buildSummaryRow('Shipping', order.shipping),
                  _buildSummaryRow('Tax', order.tax),
                  const Divider(),
                  _buildSummaryRow('Total', order.total, isTotal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, OrderModel order) {
    final allStatuses = OrderStatus.values
        .where((status) => status != OrderStatus.cancelled)
        .toList();
    
    return Row(
      children: List.generate(allStatuses.length * 2 - 1, (index) {
        // Even indexes are status icons, odd indexes are connecting lines
        if (index % 2 == 0) {
          final statusIndex = index ~/ 2;
          final status = allStatuses[statusIndex];
          final isCompleted = _isStatusCompleted(order.status, status);
          final isCurrent = order.status == status;
          
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                            ? Colors.blue
                            : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check : _getStatusIcon(status),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                            ? Colors.blue
                            : Colors.grey,
                    fontSize: 12,
                    fontWeight:
                        isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        } else {
          final statusIndex = index ~/ 2;
          final isCompleted = _isStatusCompleted(
            order.status,
            allStatuses[statusIndex + 1],
          );
          
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
            ),
          );
        }
      }),
    );
  }

  Widget _buildStatusUpdateButtons(BuildContext context, OrderModel order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
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

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              bool success = await orderProvider.updateOrderStatus(
                order.id,
                nextStatus,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order status updated successfully'),
                  ),
                );
              }
            },
            child: Text('Mark as ${_getStatusText(nextStatus)}'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              bool success = await orderProvider.updateOrderStatus(
                order.id,
                OrderStatus.cancelled,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order cancelled successfully'),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Order'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.image.isNotEmpty
                  ? Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Total Price
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Print Order'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement print functionality
                  // This basic version doesn't include printing
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Customer'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement email functionality
                  // This basic version doesn't include emailing
                },
              ),
              if (order.status != OrderStatus.cancelled)
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Cancel Order'),
                  onTap: () async {
                    Navigator.pop(context);
                    
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Order'),
                        content: const Text(
                            'Are you sure you want to cancel this order?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              
                              final orderProvider = Provider.of<OrderProvider>(
                                  context,
                                  listen: false);
                              
                              bool success = await orderProvider.updateOrderStatus(
                                order.id,
                                OrderStatus.cancelled,
                              );
                              
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order cancelled successfully'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isStatusCompleted(OrderStatus currentStatus, OrderStatus status) {
    final statusOrder = OrderStatus.values.toList();
    return statusOrder.indexOf(currentStatus) >= statusOrder.indexOf(status);
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.processing:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
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

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}