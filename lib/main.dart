import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const GeneralStoreApp());
}

class GeneralStoreApp extends StatelessWidget {
  const GeneralStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kirana POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

enum ItemType { standard, loose }

class Product {
  final String id;
  String name;
  double buyPrice;
  double sellPrice;
  double stock;
  ItemType type;
  String? unit;
  String? barcode;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.type = ItemType.standard,
    this.unit = 'pcs',
    this.barcode,
    this.imagePath,
  });
}

class CartItem {
  final Product product;
  double quantity;
  double customPrice;

  CartItem({
    required this.product,
    required this.quantity,
    required this.customPrice,
  });

  double get total => quantity * customPrice;
}

class UdhaarRecord {
  final String personName;
  final String phone;
  final double amount;
  final DateTime date;

  UdhaarRecord({
    required this.personName,
    required this.phone,
    required this.amount,
    required this.date,
  });
}

class SaleHistory {
  final String id;
  final DateTime date;
  final double total;
  final String paymentMode;
  final List<CartItem> items;
  final String? customerName;

  SaleHistory({
    required this.id,
    required this.date,
    required this.total,
    required this.paymentMode,
    required this.items,
    this.customerName,
  });
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
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final looseItems = inventory.where((i) => i.type == ItemType.loose).toList();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Loose / Weighing Items",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: looseItems.isEmpty
                        ? const Center(child: Text("No loose items added yet"))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
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
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "₹${item.sellPrice}/${item.unit}",
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text("+ New loose Item", style: TextStyle(fontSize: 16)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddNewProductDialog(defaultLoose: true);
                      },
                    ),
                  )
                ],
              ),
            );
          },
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Rate: ₹${p.sellPrice} per ${p.unit}"),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Quantity (${p.unit})",
                border: const OutlineInputBorder(),
                hintText: "e.g. 0.5 for 500g, 1.25",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            onPressed: () {
              double? q = double.tryParse(qtyCtrl.text.trim());
              if (q != null && q > 0) {
                _addToCart(p, qty: q);
              }
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
      for (var c in receiptItems) {
        c.product.stock -= c.quantity;
      }
      salesHistory.insert(
        0,
        SaleHistory(
          id: now.millisecondsSinceEpoch.toString(),
          date: now,
          total: totalAmount,
          paymentMode: mode,
          items: receiptItems,
          customerName: customerName,
        ),
      );
      cart.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Date: ${now.day}/${now.month}/${now.year}  Time: ${now.hour}:${now.minute}"),
                  Text("Mode: $mode ${customerName != null ? "($customerName)" : ""}"),
                  const Divider(),
                  ...receiptItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("${item.product.name} x ${item.quantity} ${item.product.unit}")),
                            Text("₹${item.total.toStringAsFixed(1)}"),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TOTAL PAID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("₹${totalAmount.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
                icon: const Icon(Icons.share),
                label: const Text("Share on WhatsApp"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Receipt copied to WhatsApp!")));
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("New Bill", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showOnlineQrDialog() {
    final String upiUrl = "upi://pay?pa=$upiId&pn=$shopName&am=${grandTotal.toStringAsFixed(2)}&cu=INR";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text("Scan UPI QR to Pay")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: upiUrl,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 12),
            Text("Amount: ₹${grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            Text("UPI ID: $upiId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _showPaymentSuccessBill("Online UPI");
            },
            child: const Text("Payment Received"),
          )
        ],
      ),
    );
  }

  void _showUdhaarDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add to Udhaar (Credit)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Person Name*", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Mobile Number", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Text("Total Udhaar Amount: ₹${grandTotal.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                udhaarList.add(UdhaarRecord(
                  personName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  amount: grandTotal,
                  date: DateTime.now(),
                ));
              });
              Navigator.pop(ctx);
              _showPaymentSuccessBill("Udhaar", customerName: nameCtrl.text.trim());
            },
            child: const Text("Save Udhaar"),
          )
        ],
      ),
    );
  }

  void _showAddNewProductDialog({bool defaultLoose = false}) {
    final nameCtrl = TextEditingController();
    final buyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: defaultLoose ? "kg" : "pcs");
    String? localImgPath;
    ItemType selectedType = defaultLoose ? ItemType.loose : ItemType.standard;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(selectedType == ItemType.loose ? "Add Loose Item" : "Add New Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await _picker.pickImage(source: ImageSource.camera);
                    if (picked != null) {
                      setDlgState(() => localImgPath = picked.path);
                    }
                  },
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: localImgPath != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(localImgPath!), fit: BoxFit.cover))
                        : const Icon(Icons.camera_alt, color: Colors.grey, size: 30),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Product Name*", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: buyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Buy Price", border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: sellCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:
