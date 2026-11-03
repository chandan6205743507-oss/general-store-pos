import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeneralStoreApp());
}

enum ItemType { piece, looseKg }

class Product {
  final String id;
  String name;
  double buyPrice;
  double sellPrice;
  int stock;
  ItemType type;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.type,
    this.imagePath,
  });
}

class CartItem {
  final Product product;
  double quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice {
    if (product.type == ItemType.looseKg) {
      return (product.sellPrice / 1000) * quantity;
    }
    return product.sellPrice * quantity;
  }
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

class GeneralStoreApp extends StatelessWidget {
  const GeneralStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'General Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A9E58),
          primary: const Color(0xFF7A9E58),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1;

  String storeName = "General Store";
  String storeUPI = "dukaandar@upi";
  final String appOwnerUPI = "chandan@upi";

  final List<Product> catalog = [
    Product(id: '8906115880037', name: 'Butter Delite', buyPrice: 4.0, sellPrice: 5.0, stock: 148, type: ItemType.piece),
    Product(id: 'KURKURE_01', name: 'Kurkure', buyPrice: 4.0, sellPrice: 5.0, stock: 50, type: ItemType.piece),
    Product(id: 'LOOSE_RICE', name: 'चावल (Loose Rice)', buyPrice: 34.0, sellPrice: 40.0, stock: 100, type: ItemType.looseKg),
    Product(id: 'LOOSE_SUGAR', name: 'चीनी (Loose Sugar)', buyPrice: 38.0, sellPrice: 44.0, stock: 100, type: ItemType.looseKg),
    Product(id: 'LOOSE_DAL', name: 'चना सत्तू', buyPrice: 100.0, sellPrice: 130.0, stock: 50, type: ItemType.looseKg),
  ];

  final List<CartItem> cart = [];
  final List<UdhaarRecord> udhaarRecords = [];
  double todaySalesAmount = 0.0;

  void _triggerClick() {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  void _addToCart(Product product, {double qty = 1.0}) {
    _triggerClick();
    setState(() {
      final index = cart.indexWhere((e) => e.product.id == product.id);
      if (index != -1 && product.type == ItemType.piece) {
        cart[index].quantity += 1;
      } else {
        cart.add(CartItem(product: product, quantity: qty));
      }
    });
  }

  double get grandTotal => cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Scan Barcode')),
          body: MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  final String code = barcode.rawValue!;
                  final found = catalog.firstWhere(
                    (p) => p.id == code,
                    orElse: () {
                      final newP = Product(
                        id: code,
                        name: 'Item $code',
                        buyPrice: 8.0,
                        sellPrice: 10.0,
                        stock: 50,
                        type: ItemType.piece,
                      );
                      catalog.add(newP);
                      return newP;
                    },
                  );
                  Navigator.of(context).pop();
                  _addToCart(found);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _showLooseItemDialog(Product product) {
    final gramCtrl = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${product.name} (₹${product.sellPrice.toInt()}/kg)'),
        content: TextField(
          controller: gramCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Weight (Grams me)', suffixText: 'g'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A9E58)),
            onPressed: () {
              final g = double.tryParse(gramCtrl.text) ?? 100.0;
              Navigator.pop(context);
              _addToCart(product, qty: g);
            },
            child: const Text('Add to Bill', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openLooseItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Loose Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: catalog.where((p) => p.type == ItemType.looseKg).map((p) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: _buildItemImage(p.imagePath, p.name),
                      title: Text(p.name),
                      subtitle: Text('₹${p.sellPrice.toInt()}/kg | Stock: ${p.stock}kg'),
                      onTap: () {
                        Navigator.pop(context);
                        _showLooseItemDialog(p);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE933C)),
                onPressed: () {
                  Navigator.pop(context);
                  _showProductEditOrAddDialog(forceLoose: true);
                },
                child: const Text('+ New loose Item', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductEditOrAddDialog({Product? existingProduct, bool forceLoose = false}) {
    final nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
    final buyCtrl = TextEditingController(text: existingProduct != null ? existingProduct.buyPrice.toString() : '');
    final sellCtrl = TextEditingController(text: existingProduct != null ? existingProduct.sellPrice.toString() : '');
    final currentStockCtrl = TextEditingController(text: existingProduct != null ? existingProduct.stock.toString() : '50');
    final addStockCtrl = TextEditingController(text: '');
    String? localImg = existingProduct?.imagePath;
    ItemType selectedType = forceLoose ? ItemType.looseKg : (existingProduct?.type ?? ItemType.piece);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (existingProduct != null)
                  Text(existingProduct.id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.camera);
                    if (picked != null) {
                      setDlgState(() => localImg = picked.path);
                    }
                  },
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: localImg != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(localImg!), fit: BoxFit.cover))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.grey),
                              Text('Photo Lein', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: buyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Buying price of 1 Piece (₹)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: sellCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Your selling price of 1 Piece (₹)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: currentStockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current pieces in shop', border: OutlineInputBorder())),
                if (existingProduct != null) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: addStockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '+ Naya Maal Aaya (Pieces Add Karein)',
                      hintText: 'e.g. 50',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (existingProduct != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  setState(() => catalog.remove(existingProduct));
                  Navigator.pop(context);
                },
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE933C),
                minimumSize: const Size(140, 45),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final buy = double.tryParse(buyCtrl.text) ?? 0.0;
                final sell = double.tryParse(sellCtrl.text) ?? 0.0;
                int currentStk = int.tryParse(currentStockCtrl.text) ?? 0;
                final addedStk = int.tryParse(addStockCtrl.text) ?? 0;
                currentStk += addedStk;

                if (name.isNotEmpty && sell > 0) {
                  setState(() {
                    if (existingProduct != null) {
                      existingProduct.name = name;
                      existingProduct.buyPrice = buy;
                      existingProduct.sellPrice = sell;
                      existingProduct.stock = currentStk;
                      existingProduct.imagePath = localImg;
                    } else {
                      catalog.add(Product(
                        id: 'ITEM_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        buyPrice: buy,
                        sellPrice: sell,
                        stock: currentStk,
                        type: selectedType,
                        imagePath: localImg,
                      ));
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(existingProduct != null ? 'Update' : 'Add Item', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaperReceipt(String paymentType) {
    final upiUrl = 'upi://pay?pa=$storeUPI&pn=${Uri.encodeComponent(storeName)}&am=${grandTotal.toStringAsFixed(2)}&cu=INR';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          appBar: AppBar(title: const Text('See Bill'), backgroundColor: Colors.white, elevation: 0),
          body: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      Text(storeName.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${DateTime.now().day}/${DateTime.now().month} ${TimeOfDay.now().format(context)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const Divider(thickness: 1),
                      ...cart.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.product.name),
                                Text(item.product.type == ItemType.looseKg
                                    ? '${item.quantity.toInt()}g  ₹${item.totalPrice.toStringAsFixed(0)}'
                                    : '${item.quantity.toInt()} pc  ₹${item.totalPrice.toStringAsFixed(0)}'),
                              ],
                            ),
                          )),
                      const Divider(thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${cart.length} items', style: const TextStyle(color: Colors.grey)),
                          Text('₹${grandTotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (paymentType == 'ONLINE') ...[
                        const SizedBox(height: 12),
                        QrImageView(data: upiUrl, version: QrVersions.auto, size: 140.0),
                        const Text('Scan & Pay to Store UPI', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ]
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5DECE)),
                        icon: const Icon(Icons.share, color: Colors.green),
                        label: const Text('Share on WhatsApp', style: TextStyle(color: Colors.black87)),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A9E58)),
                        icon: const Icon(Icons.receipt, color: Colors.white),
                        label: const Text('New Bill', style: TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: () {
                          setState(() {
                            todaySalesAmount += grandTotal;
                            for (var c in cart) {
                              if (c.product.type == ItemType.piece) {
                                c.product.stock -= c.quantity.toInt();
                              }
                            }
                            cart.clear();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUdhaarSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Udhaar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Person name')),
            const SizedBox(height: 10),
            Text('Udhaar: ₹${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A9E58)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  udhaarRecords.add(UdhaarRecord(
                    personName: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    amount: grandTotal,
                    date: DateTime.now(),
                  ));
                  for (var c in cart) {
                    if (c.product.type == ItemType.piece) {
                      c.product.stock -= c.quant
