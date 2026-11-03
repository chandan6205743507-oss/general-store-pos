// lib/bill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';

class BillScreen extends StatefulWidget {
  final List<ProductItem> allProducts;
  final List<UdhaarCustomer> customers;
  final Function(BillRecord) onBillCreated;
  final Function(UdhaarCustomer) onAddCustomer;
  final Function(ProductItem) onQuickAddProduct;

  const BillScreen({
    super.key,
    required this.allProducts,
    required this.customers,
    required this.onBillCreated,
    required this.onAddCustomer,
    required this.onQuickAddProduct,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final List<CartItem> cartItems = [];
  bool isTorchOn = false;
  BillRecord? completedBill;

  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _triggerScanFeedback() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _addItemToCart(ProductItem product, {double qty = 1.0, double? price}) {
    _triggerScanFeedback();
    setState(() {
      final existingIndex = cartItems.indexWhere((c) => c.product.id == product.id);
      if (existingIndex != -1) {
        cartItems[existingIndex].quantity += qty;
      } else {
        cartItems.add(CartItem(
          product: product,
          quantity: qty,
          customPrice: price ?? product.sellingPrice,
        ));
      }
    });
  }

  // Quick Sell Dialog for un-added barcodes
  void _showQuickSellDialog(String scannedBarcode) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(scannedBarcode, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 6),
              const Text("New Barcode Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2DEC9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selling Price (₹)", style: TextStyle(fontSize: 12, color: Color(0xFF755E40), fontWeight: FontWeight.bold)),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: "00", border: InputBorder.none),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC88523),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    if (price <= 0) return;

                    final quickProduct = ProductItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: "Quick Item",
                      barcode: scannedBarcode,
                      type: ItemType.barcode,
                      sellingPrice: price,
                      currentStock: 0,
                      isPending: true,
                    );
                    widget.onQuickAddProduct(quickProduct);
                    _addItemToCart(quickProduct, qty: 1.0, price: price);
                    Navigator.pop(ctx);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Loose Item Picker Dialog
  void _openLooseItemPicker() {
    final looseList = widget.allProducts.where((p) => p.type != ItemType.barcode).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(vertical: Radius.circular(20)),
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: looseList.length,
        itemBuilder: (c, i) {
          final item = looseList[i];
          return ListTile(
            leading: const Icon(Icons.shopping_bag, color: Color(0xFF9E7D46)),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.type == ItemType.looseKg ? "₹${item.sellingPrice}/kg" : "₹${item.sellingPrice}/pc"),
            onTap: () {
              Navigator.pop(ctx);
              _addItemToCart(item);
            },
          );
        },
      ),
    );
  }

  // Edit Quantity / Custom Price Dialog
  void _editCartItem(CartItem item) {
    final qtyController = TextEditingController(text: item.quantity.toStringAsFixed(0));
    final priceController = TextEditingController(text: item.customPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "How many Pieces?", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Discounted price of 1 Piece (₹)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CA655)),
                  onPressed: () {
                    setState(() {
                      item.quantity = double.tryParse(qtyController.text) ?? item.quantity;
                      item.customPrice = double.tryParse(priceController.text) ?? item.customPrice;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Udhaar Sheet
  void _openUdhaarDialog() {
    int activeTab = 0;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setUdhaarState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setUdhaarState(() => activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == 0 ? const Color(0xFFDDD2B8) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Select person", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setUdhaarState(() => activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == 1 ? const Color(0xFFDDD2B8) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text("New person", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeTab == 0) ...[
                  SizedBox(
                    height: 180,
                    child: widget.customers.isEmpty
                        ? const Center(child: Text("Koi customer nahi mila", style: TextStyle(color: Colors.black45)))
                        : ListView.builder(
                            itemCount: widget.customers.length,
                            itemBuilder: (c, i) {
                              final cust = widget.customers[i];
                              return ListTile(
                                title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(cust.phone),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _completePayment("Udhaar", customerName: cust.name);
                                },
                              );
                            },
                          ),
                  ),
                ] else ...[
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Phone number", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Person name", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CA655)),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        final newCust = UdhaarCustomer(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          pendingAmount: totalAmount,
                        );
                        widget.onAddCustomer(newCust);
                        Navigator.pop(ctx);
                        _completePayment("Udhaar", customerName: newCust.name);
                      },
                      child: const Text("Add Udhaar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completePayment(String mode, {String? customerName}) {
    if (cartItems.isEmpty) return;

    final bill = BillRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.from(cartItems),
      totalAmount: totalAmount,
      paymentMode: mode,
      customerName: customerName,
    );

    widget.onBillCreated(bill);
    setState(() {
      completedBill = bill;
      cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (completedBill != null) {
      return _buildReceiptView();
    }

    return Column(
      children: [
        // Camera View Header
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.black87,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Positioned(
                top: 10,
                right: 14,
                child: IconButton(
                  icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                  onPressed: () => setState(() => isTorchOn = !isTorchOn),
                ),
              ),
              Positioned(
                bottom: 10,
                child: TextButton.icon(
                  onPressed: () {
                    // Demo scan simulation
                    if (widget.allProducts.isNotEmpty) {
                      _addItemToCart(widget.allProducts.first);
                    } else {
                      _showQuickSellDialog("8904063254450");
                    }
                  },
                  icon: const Icon(Icons.qr_code, color: Colors.white70),
                  label: const Text("Tap to simulate scan", style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),

        // Bill Header & Loose item trigger
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bill", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7CA655))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDD2B8),
                  foregroundColor: const Color(0xFF5D4037),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _openLooseItemPicker,
                child: const Text("Loose Item", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // Cart items list
        Expanded(
          child: cartItems.isEmpty
              ? const Center(child: Text("Barcode scan karein ya Loose item add karein", style: TextStyle(color: Colors.black45)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cartItems.length,
                  itemBuilder: (c, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E2D9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          Text("${item.quantity.toStringAsFixed(0)} pc", style: const TextStyle(color: Colors.black54)),
                          const SizedBox(width: 16),
                          Text("₹${item.totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Color(0xFF7CA655)),
                            onPressed: () => _editCartItem(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                            onPressed: () => setState(() => cartItems.removeAt(index)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Bottom Payment Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, -2))],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total", style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text("₹${totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CA655),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _completePayment("Online"),
                        child: const Text("Online", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC88523),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _completePayment("Cash"),
                        child: const Text("Cash", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                  
