class CartItem {
  final String id;
  final String name;
  String attr; // Màu sắc hoặc dung lượng
  final double price;
  final String imageUrl;
  int quantity;
  bool isSelected;
  final List<String> availableColors; // Danh sách màu để chọn

  CartItem({
    required this.id,
    required this.name,
    required this.attr,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.isSelected = false,
    this.availableColors = const ["Bạc", "Xám", "Xanh"],
  });
}