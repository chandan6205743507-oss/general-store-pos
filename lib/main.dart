// lib/main.dart
import 'package:flutter/material.dart';
import 'models.dart';
import 'shop_screen.dart';
import 'bill_screen.dart';
import 'sales_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeneralStorePOSApp());
}

class GeneralStorePOSApp extends StatelessWidget {
  const GeneralStorePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'General Store POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFBF9F4),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC88523),
          primary: const Color(0xFFC88523),
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  // Master State
  final List<ProductItem> _products = [];
  final List<BillRecord> _bills = [];
  final List<UdhaarCustomer> _customers = [];

  List<ProductItem> get _pendingItems => _products.where((p) => p.isPending).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFE6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person, color: Color(0xFF7CA655), size: 20),
                      SizedBox(width: 6),
                      Text("My Shop Store", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFE6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.black54, size: 18),
                      const SizedBox(width: 6),
                      Text("Items: ${_products.length}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: My Shop
          ShopScreen(
            products: _products,
            onAddProduct: (item) {
              setState(() => _products.add(item));
            },
            onUpdateProduct: (item) {
              setState(() {
                final index = _products.indexWhere((p) => p.id == item.id);
                if (index != -1) _products[index] = item;
              });
            },
          ),

          // 1: Make Bill
          BillScreen(
            allProducts: _products,
            customers: _customers,
            onBillCreated: (bill) {
              setState(() {
                _bills.add(bill);
                // Deduct stock
                for (var cartItem in bill.items) {
                  final pIndex = _products.indexWhere((p) => p.id == cartItem.product.id);
                  if (pIndex != -1) {
                    _products[pIndex].currentStock -= cartItem.quantity;
                  }
                }
              });
            },
            onAddCustomer: (customer) {
              setState(() => _customers.add(customer));
            },
            onQuickAddProduct: (item) {
              setState(() => _products.add(item));
            },
          ),

          // 2: My Sales
          SalesScreen(
            bills: _bills,
            customers: _customers,
            pendingItems: _pendingItems,
            onSavePendingItem: (item) {
              setState(() {
                final index = _products.indexWhere((p) => p.id == item.id);
                if (index != -1) _products[index] = item;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFFFBF9F4),
          border: Border(top: BorderSide(color: Color(0xFFEBE7DD))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(Icons.storefront_rounded, "My Shop", 0),
            _buildCenterBillButton(),
            _buildNavButton(Icons.account_balance_wallet_outlined, "My Sales", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFC88523) : Colors.black45, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFC88523) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterBillButton() {
    final isSelected = _currentIndex == 1;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7CA655),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x337CA655), blurRadius: 8, offset: Offset(0, 4))]
              : [],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text("Make Bill", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
