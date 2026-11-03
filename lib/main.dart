import 'package:flutter/material.dart';
import 'models.dart';
import 'shop_screen.dart';
import 'bill_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GeneralStoreApp(),
  ));
}

class GeneralStoreApp extends StatefulWidget {
  const GeneralStoreApp({super.key});

  @override
  State<GeneralStoreApp> createState() => _GeneralStoreAppState();
}

class _GeneralStoreAppState extends State<GeneralStoreApp> {
  int _tab = 0;
  bool _isLoose = false;
  String _search = "";

  StoreConfig config = StoreConfig(
    storeName: "Damodar mahto general",
    upiId: "6202187843@upi",
    planType: "₹50 / Month",
  );

  List<Product> products = [
    Product(id: '1', name: 'kurkure', buyPrice: 4, sellPrice: 5, stock: 40, barcode: '890103001'),
    Product(id: '2', name: 'maggi', buyPrice: 12, sellPrice: 15, stock: 4, barcode: '890103002'),
    Product(id: '3', name: 'Fena powder wash', buyPrice: 65, sellPrice: 80, stock: 1, barcode: '890103003'),
    Product(id: '4', name: 'Dairy Twist', buyPrice: 4, sellPrice: 5, stock: 41, barcode: '890103004'),
    Product(id: '5', name: 'Dettol shop', buyPrice: 8, sellPrice: 10, stock: 21, barcode: '890103005'),
    Product(id: '6', name: 'Fingers pasta', buyPrice: 4, sellPrice: 5, stock: 6, barcode: '890103006'),
    Product(id: 'l1', name: 'Baba kurkure', buyPrice: 4, sellPrice: 5, stock: 5, isLoose: true, unit: 'kilo'),
    Product(id: 'l2', name: 'Chuski Kurkure', buyPrice: 4, sellPrice: 5, stock: 3, isLoose: true, unit: 'kilo'),
    Product(id: 'l3', name: 'Harsh micher', buyPrice: 8, sellPrice: 10, stock: 7, isLoose: true, unit: 'kilo'),
    Product(id: 'l4', name: 'Nimbu Bhujiya', buyPrice: 4, sellPrice: 5, stock: 14, isLoose: true, unit: 'kilo'),
  ];

  List<CartItem> cart = [];
  List<Customer> customers = [
    Customer(name: "Damodar Mahto", phone: "6202187843", udhaarAmount: 150),
  ];
  List<BillReceipt> bills = [];

  double get totalSum => cart.fold(0, (sum, i) => sum + i.total);

  void _openStoreSettings() {
    final sC = TextEditingController(text: config.storeName);
    final uC = TextEditingController(text: config.upiId);
    String selectedPlan = config.planType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Store & Plan Settings", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: sC, decoration: const InputDecoration(labelText: "Store Name", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: uC, decoration: const InputDecoration(labelText: "UPI ID (for Direct Payments)", border: OutlineInputBorder())),
                const SizedBox(height: 14),
                const Align(alignment: Alignment.centerLeft, child: Text("Subscription Plan:", style: TextStyle(fontWeight: FontWeight.bold))),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPlan,
                  items: const [
                    DropdownMenuItem(value: "₹50 / Month", child: Text("₹50 / Month Plan")),
                    DropdownMenuItem(value: "₹549 / Year", child: Text("₹549 / Year Plan (Save ₹51)")),
                  ],
                  onChanged: (val) => setDlg(() => selectedPlan = val ?? selectedPlan),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62)),
              onPressed: () {
                setState(() {
                  config.storeName = sC.text.trim();
                  config.upiId = uC.text.trim();
                  config.planType = selectedPlan;
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save Settings", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(Product p) {
    final nameC = TextEditingController(text: p.name);
    final buyC = TextEditingController(text: p.buyPrice.toString());
    final sellC = TextEditingController(text: p.sellPrice.toString());
    final stockC = TextEditingController(text: p.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.barcode ?? "8906115880037", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(controller: nameC, decoration: const InputDecoration(labelText: "Product name")),
              TextField(controller: buyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Buying price")),
              TextField(controller: sellC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Selling price (₹)")),
              TextField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Current stock")),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 28),
                    onPressed: () {
                      setState(() => products.remove(p));
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCA134)),
                      onPressed: () {
                        setState(() {
                          p.name = nameC.text;
                          p.buyPrice = double.tryParse(buyC.text) ?? p.buyPrice;
                          p.sellPrice = double.tryParse(sellC.text) ?? p.sellPrice;
                          p.stock = double.tryParse(stockC.text) ?? p.stock;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addStock() {
    final nameC = TextEditingController();
    final buyC = TextEditingController();
    final sellC = TextEditingController();
    final stockC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isLoose ? "Add Loose Item" : "Add Barcode Item"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: "Item Name")),
              TextField(controller: buyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Buy Price")),
              TextField(controller: sellC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Sell Price")),
              TextField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock Quantity")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCA134)),
            onPressed: () {
              if (nameC.text.isNotEmpty && sellC.text.isNotEmpty) {
                setState(() {
                  products.add(Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameC.text.trim(),
                    buyPrice: double.tryParse(buyC.text) ?? 0,
                    sellPrice: double.tryParse(sellC.text) ?? 0,
                    stock: double.tryParse(stockC.text) ?? 10,
                    isLoose: _isLoose,
                    unit: _isLoose ? 'kilo' : 'piece',
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openLooseSheet() {
    final list = products.where((p) => p.isLoose).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: list.map((p) => ListTile(
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("₹${p.sellPrice} / ${p.unit}"),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCA134)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => cart.add(CartItem(product: p, quantity: 1)));
            },
            child: const Text("+ Add", style: TextStyle(color: Colors.white)),
          ),
        )).toList(),
      ),
    );
  }

  void _finishBill(String mode, {String? customerName}) {
    final finalItems = List<CartItem>.from(cart);
    final total = totalSum;
    final time = DateTime.now();

    setState(() {
      for (var c in finalItems) {
        c.product.stock -= c.quantity;
      }
      bills.insert(0, BillReceipt(time: time, items: finalItems, total: total, paymentMode: mode, customerName: customerName));
      cart.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF6F5F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: const Color(0xFF232526), borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("General Store", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text("${config.storeName}\nMode: $mode ${customerName != null ? "($customerName)" : ""}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                        const Divider(),
                        ...finalItems.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(c.product.name), Text("${c.quantity.toStringAsFixed(0)} ${c.product.unit}"), Text("₹${c.total.toStringAsFixed(0)}")],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${finalItems.length} items", style: const TextStyle(color: Colors.black54)),
                            Text("₹${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE2DCC8), foregroundColor: const Color(0xFF2E7D32), minimumSize: const Size(double.infinity, 48)),
                icon: const Icon(Icons.share),
                label: const Text("Share on whatsapp"),
                onPressed: () {},
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62), minimumSize: const Size(double.infinity, 50)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("New bill", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _openStoreSettings,
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.person, color: Color(0xFF2E7D32))),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.storeName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text("Plan: ${config.planType}", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1EFEA), borderRadius: BorderRadius.circular(8)),
                child: const Text("Orders: 0", style: TextStyle(fontSize: 11, color: Colors.black54)),
              ),
              const SizedBox(width: 6),
              const Text("General Store", style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
      body: _tab == 0
          ? ShopTabScreen(
              items: products,
              isLoose: _isLoose,
              onToggleMode: () => setState(() => _isLoose = !_isLoose),
              onAddStock: _addStock,
              onEditItem: _editProduct,
              onSearch: (q) => setState(() => _search = q),
            )
          : _tab == 1
              ? MakeBillScreen(
                  config: config,
                  cart: cart,
                  customers: customers,
                  grandTotal: totalSum,
                  onOpenLoose: _openLooseSheet,
                  onAddQty: (c) => setState(() => c.quantity++),
                  onRemoveItem: (c) => setState(() => cart.remove(c)),
                  onPayDone: (mode, {customerName}) => _finishBill(mode, customerName: customerName),
                  onAddCustomer: (c) => setState(() => customers.add(c)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(child: ListTile(title: const Text("Total Completed Bills"), trailing: Text("${bills.length}", style: const TextStyle(fontWeight: FontWeight.bold)))),
                    Card(child: ListTile(title: const Text("Pending Udhaar Accounts"), trailing: Text("${customers.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))),
                    const SizedBox(height: 12),
                    const Text("Today's Bills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...bills.map((b) => Card(child: ListTile(title: Text("₹${b.total.toStringAsFixed(0)} - ${b.paymentMode}"), subtitle: Text(b.customerName ?? b.time.toString().substring(0, 16))))),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: const Color(0xFF2E7D32),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "My Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Make Bill"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "My Sales"),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'models.dart';
import 'shop_screen.dart';
import 'bill_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GeneralStoreApp(),
  ));
}

class GeneralStoreApp extends StatefulWidget {
  const GeneralStoreApp({super.key});

  @override
  State<GeneralStoreApp> createState() => _GeneralStoreAppState();
}

class _GeneralStoreAppState extends State<GeneralStoreApp> {
  int _tab = 0;
  bool _isLoose = false;
  String _search = "";

  StoreConfig config = StoreConfig(
    storeName: "Damodar mahto general",
    upiId: "6202187843@upi",
    planType: "₹50 / Month",
  );

  List<Product> products = [
    Product(
      id: '1',
      name: 'maggi',
      buyPrice: 12,
      sellPrice: 15,
      stock: 4,
      barcode: '890103001',
      imageUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=150',
    ),
    Product(
      id: '2',
      name: 'Fena powder wash',
      buyPrice: 65,
      sellPrice: 80,
      stock: 1,
      barcode: '890103002',
      imageUrl: 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=150',
    ),
    Product(
      id: '3',
      name: 'Dairy Twist',
      buyPrice: 4,
      sellPrice: 5,
      stock: 41,
      barcode: '890103003',
      imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=150',
    ),
    Product(
      id: '4',
      name: 'Dettol shop',
      buyPrice: 8,
      sellPrice: 10,
      stock: 21,
      barcode: '890103004',
      imageUrl: 'https://images.unsplash.com/photo-1607006314605-726487e49eb7?w=150',
    ),
    Product(
      id: '5',
      name: 'Fingers pasta',
      buyPrice: 4,
      sellPrice: 5,
      stock: 6,
      barcode: '890103005',
      imageUrl: 'https://images.unsplash.com/photo-1551462147-37885acc36f1?w=150',
    ),
    Product(
      id: 'l1',
      name: 'Baba kurkure',
      buyPrice: 4,
      sellPrice: 5,
      stock: 5,
      isLoose: true,
      unit: 'kilo',
      imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=150',
    ),
    Product(
      id: 'l2',
      name: 'Chuski Kurkure',
      buyPrice: 4,
      sellPrice: 5,
      stock: 3,
      isLoose: true,
      unit: 'kilo',
      imageUrl: 'https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=150',
    ),
    Product(
      id: 'l3',
      name: 'Harsh micher',
      buyPrice: 8,
      sellPrice: 10,
      stock: 7,
      isLoose: true,
      unit: 'kilo',
      imageUrl: 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=150',
    ),
    Product(
      id: 'l4',
      name: 'Nimbu Bhujiya',
      buyPrice: 4,
      sellPrice: 5,
      stock: 14,
      isLoose: true,
      unit: 'kilo',
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=150',
    ),
  ];

  List<CartItem> cart = [];
  List<Customer> customers = [
    Customer(name: "Damodar Mahto", phone: "6202187843", udhaarAmount: 150),
  ];
  List<BillReceipt> bills = [];

  double get totalSum => cart.fold(0, (sum, i) => sum + i.total);

  void _openStoreSettings() {
    final sC = TextEditingController(text: config.storeName);
    final uC = TextEditingController(text: config.upiId);
    String selectedPlan = config.planType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Store & Plan Settings", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: sC, decoration: const InputDecoration(labelText: "Store Name", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: uC, decoration: const InputDecoration(labelText: "UPI ID (for Direct Payments)", border: OutlineInputBorder())),
                const SizedBox(height: 14),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPlan,
                  items: const [
                    DropdownMenuItem(value: "₹50 / Month", child: Text("₹50 / Month Plan")),
                    DropdownMenuItem(value: "₹549 / Year", child: Text("₹549 / Year Plan (Save ₹51)")),
                  ],
                  onChanged: (val) => setDlg(() => selectedPlan = val ?? selectedPlan),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62)),
              onPressed: () {
                setState(() {
                  config.storeName = sC.text.trim();
                  config.upiId = uC.text.trim();
                  config.planType = selectedPlan;
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(Product p) {
    final nameC = TextEditingController(text: p.name);
    final buyC = TextEditingController(text: p.buyPrice.toString());
    final sellC = TextEditingController(text: p.sellPrice.toString());
    final stockC = TextEditingController(text: p.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.barcode ?? "8906115880037", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(controller: nameC, decoration: const InputDecoration(labelText: "Product name")),
              TextField(controller: buyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Buying price")),
              TextField(controller: sellC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Selling price (₹)")),
              TextField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Current stock")),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 28),
                    onPressed: () {
                      setState(() => products.remove(p));
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC88523)),
                      onPressed: () {
                        setState(() {
                          p.name = nameC.text;
                          p.buyPrice = double.tryParse(buyC.text) ?? p.buyPrice;
                          p.sellPrice = double.tryParse(sellC.text) ?? p.sellPrice;
                          p.stock = double.tryParse(stockC.text) ?? p.stock;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addStock() {
    final nameC = TextEditingController();
    final buyC = TextEditingController();
    final sellC = TextEditingController();
    final stockC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isLoose ? "Add Loose Item" : "Add Barcode Item"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: "Item Name")),
              TextField(controller: buyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Buy Price")),
              TextField(controller: sellC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Sell Price")),
              TextField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock Quantity")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC88523)),
            onPressed: () {
              if (nameC.text.isNotEmpty && sellC.text.isNotEmpty) {
                setState(() {
                  products.add(Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameC.text.trim(),
                    buyPrice: double.tryParse(buyC.text) ?? 0,
                    sellPrice: double.tryParse(sellC.text) ?? 0,
                    stock: double.tryParse(stockC.text) ?? 10,
                    isLoose: _isLoose,
                    unit: _isLoose ? 'kilo' : 'piece',
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openLooseSheet() {
    final list = products.where((p) => p.isLoose).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: list.map((p) => ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.grain)),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("₹${p.sellPrice} / ${p.unit}"),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC88523)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => cart.add(CartItem(product: p, quantity: 1)));
            },
            child: const Text("+ Add", style: TextStyle(color: Colors.white)),
          ),
        )).toList(),
      ),
    );
  }

  void _finishBill(String mode, {String? customerName}) {
    final finalItems = List<CartItem>.from(cart);
    final total = totalSum;
    final time = DateTime.now();

    setState(() {
      for (var c in finalItems) {
        c.product.stock -= c.quantity;
      }
      bills.insert(0, BillReceipt(time: time, items: finalItems, total: total, paymentMode: mode, customerName: customerName));
      cart.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF6F5F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: const Color(0xFF232526), borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("General Store", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text("${config.storeName}\nMode: $mode ${customerName != null ? "($customerName)" : ""}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                        const Divider(),
                        ...finalItems.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(c.product.name), Text("${c.quantity.toStringAsFixed(0)} ${c.product.unit}"), Text("₹${c.total.toStringAsFixed(0)}")],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${finalItems.length} items", style: const TextStyle(color: Colors.black54)),
                            Text("₹${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE2DCC8), foregroundColor: const Color(0xFF2E7D32), minimumSize: const Size(double.infinity, 48)),
                icon: const Icon(Icons.share),
                label: const Text("Share on whatsapp"),
                onPressed: () {},
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF789D62), minimumSize: const Size(double.infinity, 50)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("New bill", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _openStoreSettings,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Color(0xFF795548), size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.storeName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text("Plan: ${config.planType}", style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Text("General Store", style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
      body: _tab == 0
          ? ShopTabScreen(
              items: products,
              isLoose: _isLoose,
              onToggleMode: () => setState(() => _isLoose = !_isLoose),
              onAddStock: _addStock,
              onEditItem: _editProduct,
              onSearch: (q) => setState(() => _search = q),
            )
          : _tab == 1
              ? MakeBillScreen(
                  config: config,
                  cart: cart,
                  customers: customers,
                  grandTotal: totalSum,
                  onOpenLoose: _openLooseSheet,
                  onAddQty: (c) => setState(() => c.quantity++),
                  onRemoveItem: (c) => setState(() => cart.remove(c)),
                  onPayDone: (mode, {customerName}) => _finishBill(mode, customerName: customerName),
                  onAddCustomer: (c) => setState(() => customers.add(c)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(child: ListTile(title: const Text("Total Completed Bills"), trailing: Text("${bills.length}", style: const TextStyle(fontWeight: FontWeight.bold)))),
                    Card(child: ListTile(title: const Text("Pending Udhaar Accounts"), trailing: Text("${customers.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))),
                    const SizedBox(height: 12),
                    const Text("Today's Bills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...bills.map((b) => Card(child: ListTile(title: Text("₹${b.total.toStringAsFixed(0)} - ${b.paymentMode}"), subtitle: Text(b.customerName ?? b.time.toString().substring(0, 16))))),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.black45,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "My Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Make Bill"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "My Sales"),
        ],
      ),
    );
  }
}
