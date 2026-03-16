import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Giỏ Hàng Công Nghệ", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const Center(child: Text("Giỏ hàng trống"));
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: cart.items.length,
            itemBuilder: (ctx, i) {
              final item = cart.items[i];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                ),
                onDismissed: (_) => cart.removeItem(item.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: item.isSelected, 
                          activeColor: Colors.orange, 
                          onChanged: (_) => cart.toggleItem(item.id)
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, width: 45, height: 45, fit: BoxFit.cover),
                        ),
                      ],
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.attr, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        Text("\$${item.price}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: _buildQtyControl(item, cart),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomSheet: _buildBottomStickyBar(context),
    );
  }

  // Widget điều khiển số lượng
  Widget _buildQtyControl(item, cart) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => cart.updateQuantity(item.id, -1)),
        Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20), onPressed: () => cart.updateQuantity(item.id, 1)),
      ],
    );
  }

  // Thanh thanh toán dưới đáy
  Widget _buildBottomStickyBar(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Checkbox(value: cart.isAllSelected, activeColor: Colors.orange, onChanged: (v) => cart.toggleAll(v!)),
            const Text("Tất cả", style: TextStyle(fontSize: 12)),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Tổng thanh toán", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("\$${cart.totalAmount.toStringAsFixed(2)}", 
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: cart.totalAmount > 0 ? () => _showDetailedBill(context, cart) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // --- HÀM HIỂN THỊ BILL CHI TIẾT ---
  void _showDetailedBill(BuildContext context, CartProvider cart) {
    final selectedItems = cart.items.where((e) => e.isSelected).toList();
    double shippingFee = cart.totalAmount > 2000 ? 0 : 20.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép Bill dài nếu chọn nhiều món
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            const Text("HÓA ĐƠN CHI TIẾT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const Divider(thickness: 1),
            
            // Danh sách các mặt hàng đã chọn
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text("${item.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14))),
                        Text("\$${(item.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const Divider(thickness: 1),
            // Phần tính toán phí
            _buildPriceRow("Tạm tính:", "\$${cart.totalAmount.toStringAsFixed(2)}", isBold: false),
            _buildPriceRow("Phí vận chuyển:", shippingFee == 0 ? "Miễn phí" : "\$${shippingFee.toStringAsFixed(2)}", 
                color: shippingFee == 0 ? Colors.green : Colors.black),
            const SizedBox(height: 10),
            _buildPriceRow("TỔNG CỘNG:", "\$${(cart.totalAmount + shippingFee).toStringAsFixed(2)}", 
                isBold: true, color: Colors.redAccent, fontSize: 20),
            
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt hàng thành công!")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("THANH TOÁN NGAY", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Hàm phụ để tạo dòng giá tiền trong Bill
  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color color = Colors.black, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}