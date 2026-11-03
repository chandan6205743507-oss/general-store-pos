// lib/shop_screen.dart
import 'package:flutter/material.dart';
import 'models.dart';

class ShopScreen extends StatefulWidget {
  final List<ProductItem> products;
  final Function(ProductItem) onAddProduct;
  final Function(ProductItem) onUpdateProduct;

  const ShopScreen({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onUpdateProduct,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool isLooseMode = false;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  List<ProductItem> get filteredProducts {
    return widget.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      if (isLooseMode) {
        return matchesSearch && (p.type == ItemType.looseKg || p.type == ItemType.loosePiece);
      } else {
        return matchesSearch && (p.type == ItemType.barcode);
      }
    }).toList();
  }

  void openAddStockDialog({ProductItem? existingItem}) {
    final nameController = TextEditingController(text: existingItem?.name ?? "");
    final wholeStockMoneyController = TextEditingController();
    final piecesOrKiloBoughtController = TextEditingController();
    final sellingPriceController = TextEditingController(
      text: existingItem != null ? existingItem.sellingPrice.toStringAsFixed(0) : "",
    );
    final currentStockController = TextEditingController(
      text: existingItem != null ? existingItem.currentStock.toStringAsFixed(0) : "",
    );

    ItemType selectedType = existingItem?.type ?? (isLooseMode ? ItemType.looseKg : ItemType.barcode);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isKg = selectedType == ItemType.looseKg;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Icon/Photo & Unit / Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo / Icon selector box
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F5ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2DEC9)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isKg ? Icons.shopping_bag : Icons.inventory_2_outlined,
                                size: 36,
                                color: const Color(0xFF9E7D46),
                              ),
                              if (isLooseMode) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setDialogState(() => selectedType = ItemType.looseKg),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isKg ? const Color(0xFFDDD2B8) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text("Kilo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => setDialogState(() => selectedType = ItemType.loosePiece),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: !isKg ? const Color(0xFFDDD2B8) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text("Piece", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Product Name Box
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (existingItem != null)
                                Text(
                                  existingItem.barcode ?? existingItem.id,
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F7EE),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2DEC9)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Product name", style: TextStyle(fontSize: 11, color: Color(0xFF755E40), fontWeight: FontWeight.bold)),
                                    TextField(
                                      controller: nameController,
                                      enabled: existingItem == null,
                                      decoration: const InputDecoration(
                                        hintText: "Write here",
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 1. Money you paid for whole stock
                    _buildFieldRow("Money you paid for whole stock (₹)", wholeStockMoneyController),
                    const SizedBox(height: 10),

                    // 2. No. of kilos / pieces bought
                    _buildFieldRow(
                      isKg ? "No. of kilos bought in that money" : "No. of pieces bought in that money",
                      piecesOrKiloBoughtController,
                    ),
                    const SizedBox(height: 10),

                    // 3. Selling price of 1 Kg / 1 Piece
                    _buildFieldRow(
                      isKg ? "Your selling price of 1 Kg" : "Your selling price of 1 Piece(₹)",
                      sellingPriceController,
                    ),
                    const SizedBox(height: 10),

                    // 4. Current pieces / kilos in shop
                    _buildFieldRow(
                      isKg ? "Current kilos in shop" : "Current pieces in shop",
                      currentStockController,
                    ),

                    const SizedBox(height: 20),

                    // Add / Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC88523),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final double sellPrice = double.tryParse(sellingPriceController.text) ?? 0.0;
                          final double stockQty = double.tryParse(currentStockController.text) ?? 0.0;
                          final double buyPrice = double.tryParse(wholeStockMoneyController.text) ?? 0.0;

                          if (nameController.text.trim().isEmpty || sellPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Kripya sahi naam aur bechne ka rate dalein")),
                            );
                            return;
                          }

                          if (existingItem != null) {
                            existingItem.sellingPrice = sellPrice;
                            existingItem.currentStock += stockQty;
                            if (buyPrice > 0) existingItem.buyingPrice = buyPrice;
                            widget.onUpdateProduct(existingItem);
                          } else {
                            final newItem = ProductItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameController.text.trim(),
                              barcode: isLooseMode ? null : DateTime.now().millisecondsSinceEpoch.toString(),
                              type: selectedType,
                              sellingPrice: sellPrice,
                              currentStock: stockQty,
                              buyingPrice: buyPrice,
                            );
                            widget.onAddProduct(newItem);
                          }

                          Navigator.pop(ctx);
                        },
                        child: const Text("Add stock", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldRow(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2D9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                hintText: "00",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar & Barcode/Loose toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0DDD5)),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 22),
                      hintText: isLooseMode ? "Search loose item" : "Search barcode item",
                      hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Switch Button: Barcode vs Loose
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: !isLooseMode ? const Color(0xFF9E7D46) : Colors.black38,
                      ),
                      onPressed: () => setState(() => isLooseMode = false),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.shopping_bag,
                        color: isLooseMode ? const Color(0xFF9E7D46) : Colors.black38,
                      ),
                      onPressed: () => setState(() => isLooseMode = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Golden Action Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC88523),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => openAddStockDialog(),
              child: Text(
                isLooseMode ? "Stock loose item" : "Stock barcode items",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),

        // Product Cards List
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Text(
                    isLooseMode ? "Koi loose item nahi mila" : "Koi barcode item nahi mila",
                    style: const TextStyle(color: Colors.black45),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = filteredProducts[index];
                    final isLowStock = item.currentStock <= 5;

                    return GestureDetector(
                      onTap: () => openAddStockDialog(existingItem: item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFECE4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EFE6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.type == ItemType.looseKg ? Icons.shopping_bag : Icons.fastfood,
                                color: const Color(0xFF9E7D46),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.type == ItemType.looseKg
                                        ? "${item.currentStock.toStringAsFixed(0)} kilo"
                                        : "${item.currentStock.toStringAsFixed(0)} piece",
                                    style: TextStyle(
                                      color: isLowStock ? const Color(0xFFE57373) : Colors.black45,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.type == ItemType.looseKg
                                  ? "₹${item.sellingPrice.toStringAsFixed(0)}/kg"
                                  : "₹${item.sellingPrice.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                   
