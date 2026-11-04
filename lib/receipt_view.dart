import 'package:flutter/material.dart';
import 'models.dart';

class ReceiptView extends StatelessWidget {
  final BillRecord bill;
  final VoidCallback onNewBill;

  const ReceiptView({
    super.key,
    required this.bill,
    required this.onNewBill,
  });

  @override
  Widget build(BuildContext context) {
    final String dateStr = DateTime.now().toString();
    final String formattedDate = dateStr.length >= 16 ? dateStr.substring(0, 16) : dateStr;
    final String totalBillAmount = bill.totalAmount.toStringAsFixed(0);

    final List<Widget> itemRows = [];
    for (int i = 0; i < bill.items.length; i++) {
      final CartItem currentItem = bill.items[i];
      final bool isKg = currentItem.product.type == ItemType.looseKg;
      final String qtyStr = isKg ? currentItem.quantity.toString() : currentItem.quantity.toStringAsFixed(0);
      final String priceStr = currentItem.totalPrice.toStringAsFixed(0);

      itemRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${currentItem.product.name} (${qtyStr}x)",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                "₹$priceStr",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E2D9)),
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "GENERAL STORE",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    "Date: $formattedDate",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
                if (bill.customerName != null) ...[
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      "Customer: ${bill.customerName}",
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFC88523)),
                    ),
                  ),
                ],
                const Divider(height: 24),
                ...itemRows,
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Mode", style: TextStyle(color: Colors.black54)),
                    Text(bill.paymentMode, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Bill", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      "₹$totalBillAmount",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7CA655)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDDD2B8),
              foregroundColor: const Color(0xFF4A3426),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text("Share on WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7CA655),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onNewBill,
            icon: const Icon(Icons.receipt_long),
            label: const Text("New Bill", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
