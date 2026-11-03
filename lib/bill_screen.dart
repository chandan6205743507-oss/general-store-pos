import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'models.dart';

class MakeBillScreen extends StatelessWidget {
  final StoreConfig config;
  final List<CartItem> cart;
  final List<Customer> customers;
  final double grandTotal;
  final VoidCallback onOpenLoose;
  final Function(CartItem) onAddQty;
  final Function(CartItem) onRemoveItem;
  final Function(String, {String? customerName}) onPayDone;
  final Function(Customer) onAddCustomer;

  const MakeBillScreen({
    super.key,
    required this.config,
    required this.cart,
    required this.customers,
    required this.grandTotal,
    required this.onOpenLoose,
    required this.onAddQty,
    required this.onRemoveItem,
    required this.onPayDone,
    required this.onAddCustomer,
  });

  void _showDynamicQR(BuildContext context) {
    final upiUrl = "upi://pay?pa=${config.upiId}&pn=${Uri.encodeComponent(config.storeName)}&am=${grandTotal.toStringAsFixed(2)}&cu=INR";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(config.storeName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
              child: QrImageView(data: upiUrl, version: QrVersions.auto, size: 200.0),
            ),
            const SizedBox(height: 10),
            Text("₹${grandTotal.toStringAsFixed(1)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            Text("Scan via Any UPI App\nID: ${config.upiId}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62), minimumSize: const Size(double.infinity, 44)),
            onPressed: () {
              Navigator.pop(ctx);
              onPayDone("Online UPI");
            },
            child: const Text("Payment Received", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUdhaar(BuildContext context) {
    int activeTab = 0;
    final phoneC = TextEditingController();
    final nameC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setD(() => activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == 0 ? const Color(0xFFE5DEC3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Select person", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setD(() => activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == 1 ? const Color(0xFFE5DEC3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text("New person", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (activeTab == 0) ...[
                  TextField(decoration: InputDecoration(hintText: "Search name or phone number", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 10),
                  ...customers.map((c) => ListTile(
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.phone),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62)),
                          onPressed: () {
                            c.udhaarAmount += grandTotal;
                            Navigator.pop(ctx);
                            onPayDone("Udhaar", customerName: c.name);
                          },
                          child: const Text("Select", style: TextStyle(color: Colors.white)),
                        ),
                      )),
                ] else ...[
                  TextField(controller: phoneC, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Phone number", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 10),
                  TextField(controller: nameC, decoration: InputDecoration(labelText: "Person name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62)),
                      onPressed: () {
                        if (nameC.text.isNotEmpty) {
                          final cust = Customer(name: nameC.text.trim(), phone: phoneC.text.trim(), udhaarAmount: grandTotal);
                          onAddCustomer(cust);
                          Navigator.pop(ctx);
                          onPayDone("Udhaar", customerName: cust.name);
                        }
                      },
                      child: const Text("Add Udhaar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black87,
              child: Center(
                child: Container(
                  width: 220,
                  height: 100,
                  decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 2), borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text("Camera Scanner Area", style: TextStyle(color: Colors.white60, fontSize: 13))),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bill", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF789D62))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8DFCE), elevation: 0),
                onPressed: onOpenLoose,
                child: const Text("Loose Item", style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: cart.isEmpty
              ? const Center(child: Text("Cart is empty.\nScan barcode or add items from Shop", textAlign: TextAlign.center))
              : ListView.separated(
                  itemCount: cart.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = cart[i];
                    return ListTile(
                      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF3EFE6), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.fastfood, color: Color(0xFFDCA134))),
                      title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.quantity.toStringAsFixed(0)} ${item.product.unit}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("₹${item.total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.green, size: 20), onPressed: () => onAddQty(item)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.orange, size: 20), onPressed: () => onRemoveItem(item)),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text("₹${grandTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62)),
                onPressed: cart.isEmpty ? null : () => _showDynamicQR(context),
                child: const Text("Online", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCA134)),
                onPressed: cart.isEmpty ? null : () => onPayDone("Cash"),
                child: const Text("Cash", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5DEC3)),
                onPressed: cart.isEmpty ? null : () => _showUdhaar(context),
                child: const Text("Udhaar", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }
}
