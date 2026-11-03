import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'models.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Kirana POS',
    debugShowCheckedModeBanner: false,
    home: MainNavigationScreen(),
  ));
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1;
  final String shopName = "Mahto Store";
  final String upiId = "6202187843@upi";
  final ImagePicker _picker = ImagePicker();

  List<Product> inventory = [
    Product(id: '1', name: 'Aashirvaad Atta 5kg', buyPrice: 210, sellPrice: 245, stock: 15, barcode: '890103000001'),
    Product(id: '2', name: 'Tata Salt 1kg', buyPrice: 22, sellPrice: 28, stock: 40, barcode: '890103000002'),
    Product(id: '3', name: 'Fortune Mustard Oil 1L', buyPrice: 130, sellPrice: 148, stock: 25, barcode: '890103000003'),
    Product(id: '4', name: 'Maggi 2-Min Noodles', buyPrice: 11.5, sellPrice: 14, stock: 80, barcode: '890103000004'),
    Product(id: 'l1', name: 'Sugar (Chini)', buyPrice: 38, sellPrice: 44, stock: 100, type: ItemType.loose, unit: 'kg'),
    Product(id: 'l2', name: 'Basmati Rice', buyPrice: 65, sellPrice: 85, stock: 150, type: ItemType.loose, unit: 'kg'),
    Product(id: 'l3', name: 'Arhar Dal', buyPrice: 120, sellPrice: 145, stock: 60, type: ItemType.loose, unit: 'kg'),
    Product(id: 'l4', name: 'Potato (Aloo)', buyPrice: 18, sellPrice: 25, stock: 80, type: ItemType.loose, unit: 'kg'),
  ];

  List<CartItem> cart = [];
  List<UdhaarRecord> udhaarList = [];
  List<SaleHistory> salesHistory = [];

  double get grandTotal => cart.fold(0, (sum, item) => sum + item.total);

  Widget _buildItemImage(String? imagePath, String name) {
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(imagePath), width: 44, height: 44, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 18),
        ),
      ),
    );
  }

  void _addToCart(Product p, {double qty = 1.0}) {
    setState(() {
      int idx = cart.indexWhere((c) => c.product.id == p.id);
      if (idx >= 0) {
        cart[idx].quantity += qty;
      } else {
        cart.add(CartItem(product: p, quantity: qty, customPrice: p.sellPrice));
      }
    });
  }

  void _showLooseItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final looseItems = inventory.where((i) => i.type == ItemType.loose).toList();
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Loose / Weighing Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: looseItems.length,
                  itemBuilder: (context, i) {
                    final item = looseItems[i];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showWeightInputDialog(item);
                      },
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildItemImage(item.imagePath, item.name),
                              const SizedBox(height: 6),
                              Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("₹${item.sellPrice}/${item.unit}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeightInputDialog(Product p) {
    final qtyCtrl = TextEditingController(text: "1");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Enter Weight/Qty for ${p.name}"),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(labelText: "Quantity (${p.unit})", border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              double? q = double.tryParse(qtyCtrl.text.trim());
              if (q != null && q > 0) _addToCart(p, qty: q);
              Navigator.pop(ctx);
            },
            child: const Text("Add to Bill"),
          )
        ],
      ),
    );
  }

  void _showPaymentSuccessBill(String mode, {String? customerName}) {
    final receiptItems = List<CartItem>.from(cart);
    final totalAmount = grandTotal;
    final now = DateTime.now();

    setState(() {
      for (var c in receiptItems) { c.product.stock -= c.quantity; }
      salesHistory.insert(0, SaleHistory(id: now.millisecondsSinceEpoch.toString(), date: now, total: totalAmount, paymentMode: mode, items: receiptItems, customerName: customerName));
      cart.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Text(shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Mode: $mode ${customerName != null ? "($customerName)" : ""}"),
            const Divider(),
            Expanded(
              child: ListView(
                children: receiptItems.map((item) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("${item.product.name} x ${item.quantity}"), Text("₹${item.total.toStringAsFixed(1)}")],
                )).toList(),
              ),
            ),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("TOTAL PAID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹${totalAmount.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
            ]),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Done / New Bill")),
          ],
        ),
      ),
    );
  }

  Widget _buildMakeBillScreen() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          height: 100,
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () { if (inventory.isNotEmpty) _addToCart(inventory.first); },
                child: const Text("Scan Barcode"),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bill (${cart.length} items)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFF3E0), foregroundColor: const Color(0xFFE65100)),
                icon: const Icon(Icons.scale, size: 18),
                label: const Text("Loose Item"),
                onPressed: _showLooseItemSheet,
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cart.length,
            itemBuilder: (ctx, i) {
              final item = cart[i];
              return ListTile(
                leading: _buildItemImage(item.product.imagePath, item.product.name),
                title: Text(item.product.name),
                subtitle: Text("₹${item.customPrice} x ${item.quantity}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => item.quantity > 1 ? item.quantity-- : cart.removeAt(i))),
                    Text("${item.quantity}"),
                    IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => item.quantity++)),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Grand Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("₹${grandTotal.toStringAsFixed(1)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: cart.isEmpty ? null : () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Scan UPI QR"),
                            content: SizedBox(
                              width: 180,
                              height: 180,
                              child: QrImageView(data: "upi://pay?pa=$upiId&pn=$shopName&am=${grandTotal.toStringAsFixed(2)}&cu=INR"),
                            ),
                            actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); _showPaymentSuccessBill("Online UPI"); }, child: const Text("Done"))],
                          ),
                        );
                      },
                      child: const Text("Online"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      onPressed: cart.isEmpty ? null : () => _showPaymentSuccessBill("Cash"),
                      child: const Text("Cash"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                      onPressed: cart.isEmpty ? null : () {
                        final nCtrl = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Udhaar Details"),
                            content: TextField(controller: nCtrl, decoration: const InputDecoration(labelText: "Customer Name")),
                            actions: [ElevatedButton(onPressed: () {
                              udhaarList.add(UdhaarRecord(personName: nCtrl.text, phone: '', amount: grandTotal, date: DateTime.now()));
                              Navigator.pop(ctx);
                              _showPaymentSuccessBill("Udhaar", customerName: nCtrl.text);
                            }, child: const Text("Save"))],
                          ),
                        );
                      },
                      child: const Text("Udhaar"),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMyShopScreen() {
    return ListView.builder(
      itemCount: inventory.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: _buildItemImage(inventory[i].imagePath, inventory[i].name),
        title: Text(inventory[i].name),
        subtitle: Text("Price: ₹${inventory[i].sellPrice} | Stock: ${inventory[i].stock} ${inventory[i].unit}"),
        trailing: IconButton(icon: const Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(inventory[i])),
      ),
    );
  }

  Widget _buildMySalesScreen() {
    double totalRevenue = salesHistory.fold(0, (sum, s) => sum + s.total);
    double totalUdhaar = udhaarList.fold(0, (sum, u) => sum + u.amount);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(child: ListTile(title: const Text("Total Sales"), trailing: Text("₹$totalRevenue", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)))),
          Card(child: ListTile(title: const Text("Total Udhaar"), trailing: Text("₹$totalUdhaar", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentIndex == 0 ? "My Shop" : _currentIndex == 1 ? shopName : "Sales & Reports"), backgroundColor: Colors.green.shade800, foregroundColor: Colors.white),
      body: _currentIndex == 0 ? _buildMyShopScreen() : _currentIndex == 1 ? _buildMakeBillScreen() : _buildMySalesScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Make Bill'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Sales'),
        ],
      ),
    );
  }
}
