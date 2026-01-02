class MarketplaceItemModel {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String location;
  final DateTime createdAt;
  final String category;
  final String description;
  final String sellerId;
  final bool isSaved;

  MarketplaceItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
    required this.category,
    required this.description,
    required this.sellerId,
    this.isSaved = false,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';
}
