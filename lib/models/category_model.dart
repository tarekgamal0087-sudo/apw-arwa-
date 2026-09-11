class CategoryModel {
  final String id;
  final String name;
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.order,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      order: (map['order'] ?? 0) is int
          ? map['order']
          : (map['order'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'order': order,
    };
  }
}
