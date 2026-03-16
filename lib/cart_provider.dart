import 'package:flutter/material.dart';
import 'cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [
    // --- NHÓM ĐIỆN THOẠI ---
    CartItem(id: '1', name: 'iPhone 15 Pro Max', attr: 'Titan tự nhiên', price: 1200.0, imageUrl: 'https://picsum.photos/id/160/200', availableColors: ["Titan", "Đen", "Trắng"]),
    CartItem(id: '2', name: 'Samsung S24 Ultra', attr: 'Xám Titan', price: 1150.0, imageUrl: 'https://picsum.photos/id/1/200', availableColors: ["Xám", "Vàng", "Tím"]),
    CartItem(id: '3', name: 'Google Pixel 8 Pro', attr: 'Xanh Mint', price: 900.0, imageUrl: 'https://picsum.photos/id/2/200', availableColors: ["Xanh", "Đen", "Sứ"]),
    CartItem(id: '4', name: 'Xiaomi 14 Ultra', attr: 'Đen nhám', price: 1000.0, imageUrl: 'https://picsum.photos/id/3/200'),
    CartItem(id: '5', name: 'Oppo Find X7 Ultra', attr: 'Da nâu', price: 950.0, imageUrl: 'https://picsum.photos/id/4/200'),

    // --- NHÓM MÁY TÍNH & MÁY TÍNH BẢNG ---
    CartItem(id: '6', name: 'MacBook Pro M3', attr: 'Space Gray', price: 2000.0, imageUrl: 'https://picsum.photos/id/5/200', availableColors: ["Gray", "Silver"]),
    CartItem(id: '7', name: 'Surface Laptop 5', attr: 'Bạch kim', price: 1300.0, imageUrl: 'https://picsum.photos/id/6/200'),
    CartItem(id: '8', name: 'iPad Pro M2', attr: 'Bạc', price: 999.0, imageUrl: 'https://picsum.photos/id/7/200'),
    CartItem(id: '9', name: 'Samsung Tab S9', attr: 'Đen Graphite', price: 800.0, imageUrl: 'https://picsum.photos/id/8/200'),
    CartItem(id: '10', name: 'Dell XPS 13', attr: 'Trắng', price: 1400.0, imageUrl: 'https://picsum.photos/id/9/200'),

    // --- NHÓM PHỤ KIỆN ---
    CartItem(id: '11', name: 'AirPods Pro 2', attr: 'Trắng', price: 249.0, imageUrl: 'https://picsum.photos/id/10/200'),
    CartItem(id: '12', name: 'Apple Watch Ultra 2', attr: 'Cam', price: 799.0, imageUrl: 'https://picsum.photos/id/11/200'),
    CartItem(id: '13', name: 'Sạc dự phòng 20k mAh', attr: 'Đen', price: 50.0, imageUrl: 'https://picsum.photos/id/12/200'),
    CartItem(id: '14', name: 'Bàn phím cơ Logi', attr: 'RGB', price: 120.0, imageUrl: 'https://picsum.photos/id/13/200'),
    CartItem(id: '15', name: 'Chuột Magic Mouse', attr: 'Trắng', price: 79.0, imageUrl: 'https://picsum.photos/id/14/200'),
    
    // --- NHÓM GIẢI TRÍ ---
    CartItem(id: '16', name: 'PlayStation 5', attr: 'Standard', price: 499.0, imageUrl: 'https://picsum.photos/id/15/200'),
    CartItem(id: '17', name: 'Nintendo Switch Oled', attr: 'Neon', price: 350.0, imageUrl: 'https://picsum.photos/id/16/200'),
    CartItem(id: '18', name: 'Loa Marshall Stanmore', attr: 'Nâu', price: 300.0, imageUrl: 'https://picsum.photos/id/17/200'),
    CartItem(id: '19', name: 'Tai nghe Sony XM5', attr: 'Đen', price: 350.0, imageUrl: 'https://picsum.photos/id/18/200'),
    CartItem(id: '20', name: 'Kindle Paperwhite 5', attr: 'Đen', price: 150.0, imageUrl: 'https://picsum.photos/id/19/200'),
  ];

  List<CartItem> get items => _items;

  // Tổng tiền nhảy số tự động
  double get totalAmount => _items
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  bool get isAllSelected => _items.isNotEmpty && _items.every((item) => item.isSelected);

  void toggleAll(bool value) {
    for (var item in _items) {
      item.isSelected = value;
    }
    notifyListeners();
  }

  void toggleItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  void updateColor(String id, String newColor) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].attr = newColor;
      notifyListeners();
    }
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1 && _items[index].quantity + delta > 0) {
      _items[index].quantity += delta;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}