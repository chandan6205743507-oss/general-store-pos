// lib/sales_screen.dart
import 'package:flutter/material.dart';
import 'models.dart';

class SalesScreen extends StatefulWidget {
  final List<BillRecord> bills;
  final List<UdhaarCustomer> customers;
  final List<ProductItem> pendingItems;
  final Function(ProductItem) onSavePendingItem;

  const SalesScreen({
    super.key,
    required this.bills,
    required this.customers,
    required this.pendingItems,
    required this.onSavePendingItem,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  int selectedTab = 0; // 0: Sales, 1: Udhaar, 2: Pending
  String udhaarSearchQuery = "";

  double get todaySalesTotal {
    final now = DateTime.now();
    return widget.bills.where((b) {
      return b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day &&
          b.paymentMode != "Udhaar";
    }).fold(0.0, (sum, b) => sum + b.totalAmount);
  }

  void _showPendingApprovalDialog(ProductItem item) {
    final buyingPriceController = TextEditingController();
    final sellingPriceController = TextEditingController(text: item.sellingPrice.toStringAsFixed(0));
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFE6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fastfood, color: Color(0xFF9E7D46), size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.barcode ?? item.id, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputBox("Buying price of 1 Piece", buyingPriceController),
              const SizedBox(height: 10),
              _buildInputBox("Your selling price of 1 Piece(₹)", sellingPriceController),
              const SizedBox(height: 10),
              _buildInputBox("Current pieces in shop", stockController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CA655),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final buy = double.tryParse(buyingPriceController.text) ?? 0.0;
                    final sell = double.tryParse(sellingPriceController.text) ?? item.sellingPrice;
                    final stock = double.tryParse(stockController.text) ?? 0.0;

                    item.buyingPrice = buy;
                    item.sellingPrice = sell;
                    item.currentStock = stock;
                    item.isPending = false;

                    widget.onSavePendingItem(item);
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2D9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13))),
          SizedBox(
            width: 70,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "00", border: InputBorder.none, isDense: true),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: SafeArea(
        child: Column(
          children: [
            // Top Tabs: Sales | Udhaar | Pending
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFECE4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildTopTab("Sales", 0),
                    _buildTopTab("Udhaar", 1),
                    _buildTopTab("Pending (${widget.pendingItems.length})", 2),
                  ],
                ),
              ),
            ),

            Expanded(
              child: selectedTab == 0
                  ? _buildSalesView()
                  : selectedTab == 1
                      ? _buildUdhaarView()
                      : _buildPendingView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTab(String title, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDDD2B8) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF4A3B2C) : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top Card with Sales & Graph
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E2D9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sales of day", style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Text("₹${todaySalesTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFE6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("November 2026", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (widget.pendingItems.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => selectedTab = 2),
                  child: const Text(
                    "Clear Pending items to see profit. ➤",
                    style: TextStyle(color: Color(0xFFC88523), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Bar Chart Simulation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildGraphBar("₹0", "1 Nov", 10),
                  _buildGraphBar("₹0", "2 Nov", 10),
                  _buildGraphBar("₹${todaySalesTotal.toStringAsFixed(0)}", "Today", todaySalesTotal > 0 ? 80 : 10, isHighlight: true),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        const Text("Bills of the day", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),

        if (widget.bills.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Aaj abhi tak koi bill nahi bana", style: TextStyle(color: Colors.black45)),
            ),
          )
        else
          ...widget.bills.reversed.map((b) {
            final timeStr = "${b.date.hour.toString().padLeft(2, '0')}:${b.date.minute.toString().padLeft(2, '0')}";
            final isOnline = b.paymentMode == "Online";

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E2D9)),
              ),
              child: Row(
                children: [
                  Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.paymentMode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text("${b.items.length} Items", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(width: 14),
                  Text("₹${b.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGraphBar(String amount, String day, double height, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(amount, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFF7CA655) : const Color(0xFFDDD2B8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildUdhaarView() {
    final filteredCusts = widget.customers.where((c) {
      return c.name.toLowerCase().contains(udhaarSearchQuery.toLowerCase()) || c.phone.contains(udhaarSearchQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E2D9)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => udhaarSearchQuery = val),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black45),
                hintText: "Search name or phone number",
                hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredCusts.isEmpty
              ? const Center(child: Text("Koi udhaar record nahi mila", style: TextStyle(color: Colors.black45)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCusts.length,
                  itemBuilder: (c, i) {
                    final cust = filteredCusts[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E2D9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(cust.phone, style: const TextStyle(color: Colors.black45, fontSize: 13)),
                              ],
                            ),
                          ),
                          Text(
                            "₹${cust.pendingAmount.toStringAsFixed(0)}",
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPendingView() {
    if (widget.pendingItems.isEmpty) {
      return const Center(child: Text("Sabhi item stock me add hain (No Pending)", style: TextStyle(color: Colors.black45)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.pendingItems.length,
      itemBuilder: (c, i) {
        final item = widget.pendingItems[i];
        return GestureDetector(
          onTap: () => _showPendingApprovalDialog(item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E2D9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFC88523), size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("Selling: ₹${item.sellingPrice.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7CA655),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Add details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
