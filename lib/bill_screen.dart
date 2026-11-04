import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'receipt_view.dart';

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
    double sum = 0.0;
    for (int i = 0; i < cartItems.length; i++) {
      sum += cartItems[i].totalPrice;
    }
    return sum;
  }

  void _triggerScanFeedback() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _addItemToCart(ProductItem product, {double qty = 1.0, double? price}) {
    _triggerScanFeedback();
    setState(() {
      final int existingIndex = cartItems.indexWhere((c) => c.product.id == product.id);
      if (existingIndex != -1) {
        cartItems[existingIndex].quantity += qty;
      } else {
        cartItems.add(
          CartItem(
            product: product,
            quantity: qty,
            customPrice: price ?? product.sellingPrice,
          ),
        );
      }
    });
  }

  void _showQuickSellDialog(String scannedBarcode) {
    final TextEditingController priceController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  scannedBarcode,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "New Barcode Item",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5DECA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Selling Price (₹)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8D6E63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: "00",
                          hintStyle: TextStyle(color: Colors.black26),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC88523),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final double price = double.tryParse(priceController.text.trim()) ?? 0.0;
                      if (price <= 0) return;

                      final ProductItem quickProduct = ProductItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: "Item $scannedBarcode",
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
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openLooseItemPicker() {
    final List<ProductItem> looseList = widget.allProducts.where((p) => p.type != ItemType.barcode).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Loose Item",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(height: 1),
              looseList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text("Loose items list khali hai. Shop se add karein."),
                      ),
                    )
                  : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: looseList.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (c, i) {
                          final ProductItem item = looseList[i];
                          final bool isKg = item.type == ItemType.looseKg;
                          final String priceLabel = isKg ? "₹${item.sellingPrice}/kg" : "₹${item.sellingPrice}/pc";

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF1EADB),
                              child: Icon(
                                isKg ? Icons.scale : Icons.category,
                                color: const Color(0xFF8D6E63),
                              ),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(priceLabel),
                            trailing: const Icon(Icons.add_circle, color: Color(0xFF7CA655), size: 28),
                            onTap: () {
                              Navigator.pop(ctx);
                              _addItemToCart(item);
                            },
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

  void _editCartItem(CartItem item) {
    final bool isKg = item.product.type == ItemType.looseKg;
    final TextEditingController qtyController = TextEditingController(
      text: isKg ? item.quantity.toString() : item.quantity.toStringAsFixed(0),
    );
    final TextEditingController priceController = TextEditingController(
      text: item.customPrice.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isKg ? "Quantity (in Kg)" : "How many Pieces?",
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isKg ? "Rate per Kg (₹)" : "Discounted price of 1 Piece (₹)",
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CA655),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final double newQty = double.tryParse(qtyController.text.trim()) ?? item.quantity;
                      final double newPrice = double.tryParse(priceController.text.trim()) ?? item.customPrice;
                      if (newQty > 0 && newPrice >= 0) {
                        setState(() {
                          item.quantity = newQty;
                          item.customPrice = newPrice;
                        });
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openUdhaarDialog() {
    int activeTab = 0;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setUdhaarState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setUdhaarState(() {
                                activeTab = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activeTab == 0 ? const Color(0xFFDDD2B8) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Select person",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: activeTab == 0 ? const Color(0xFF4A3426) : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setUdhaarState(() {
                                activeTab = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activeTab == 1 ? const Color(0xFFDDD2B8) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "New person",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: activeTab == 1 ? const Color(0xFF4A3426) : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (activeTab == 0)
                      SizedBox(
                        height: 200,
                        child: widget.customers.isEmpty
                            ? const Center(
                                child: Text("Koi customer nahi mila", style: TextStyle(color: Colors.black45)),
                              )
                            : ListView.separated(
                                itemCount: widget.customers.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (c, i) {
                                  final UdhaarCustomer cust = widget.customers[i];
                                  return ListTile(
                                    dense: true,
                                    title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(cust.phone),
                                    trailing: Text(
                                      "Old: ₹${cust.pendingAmount.toStringAsFixed(0)}",
                                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                                    ),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _completePayment("Udhaar", customerName: cust.name);
                                    },
                                  );
                                },
                              ),
                      )
                    else
                      Column(
                        children: [
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Phone number",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Person name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7CA655),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                final String name = nameController.text.trim();
                                if (name.isEmpty) return;

                                final UdhaarCustomer newCust = UdhaarCustomer(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: name,
                                  phone: phoneController.text.trim(),
                                  pendingAmount: totalAmount,
                                );
                                widget.onAddCustomer(newCust);
                                Navigator.pop(ctx);
                                _completePayment("Udhaar", customerName: newCust.name);
                              },
                              child: const Text(
                                "Add Udhaar",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                    
