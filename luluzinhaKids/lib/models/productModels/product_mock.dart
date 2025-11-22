import 'package:luluzinhakids/models/productModels/product_model.dart';

final Map<String, List<Product>> mockProduct = {
  "Conjuntos": [
    Product(
      id: 1,
      name: "Conjunto Tricot",
      costPrice: 99.90,
      salePrice: 159.90,
      description:
          "Conjunto Tricot Infantil Feminino Luluzinha Kids Blusa e Calça em Tricot Macio e Confortável para o Dia a Dia das Crianças.",
      category: "Sets",
      nameImage: "assets/images/conjunto_tricot.jpeg",
      availableSizes: ["04", "06", "08"],
    ),
    Product(
      id: 2,
      name: "Conjunto Moletom",
      costPrice: 109.90,
      salePrice: 179.90,
      description:
          "Conjunto Moletom Infantil Feminino Luluzinha Kids Blusa e Calça em Moletom Quentinho e Estiloso para o Dia a Dia das Crianças.",
      category: "Sets",
      nameImage: "assets/images/moletom_beje.jpeg",
      availableSizes: ["04", "06", "08"],
    ),
  ],
  "Calças": [
    Product(
      id: 3,
      name: "Calça Saruel",
      costPrice: 69.90,
      salePrice: 89.90,
      description:
          "Calça Saruel Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Pants",
      nameImage: "assets/images/calca_saruel.jpg",
      availableSizes: ["04", "06", "08", "10", "12"],
    ),
    Product(
      id: 4,
      name: "Calça Jeans",
      costPrice: 99.90,
      salePrice: 119.90,
      description:
          "Calça Jeans Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Pants",
      nameImage: "assets/images/categoria_calcas.jpg",
      availableSizes: ["02", "04", "06", "08"],
    ),
  ],
  "Camisetas": [
    Product(
      id: 5,
      name: "Camiseta Adidas",
      costPrice: 49.90,
      salePrice: 69.90,
      description:
          "Camitas adidas Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Camisetas",
      nameImage: "assets/images/categoria_camisetas.jpg",
      availableSizes: ["08", "10", "12", "14"],
    ),
    Product(
      id: 6,
      name: "Camiseta Estampada",
      costPrice: 39.90,
      salePrice: 59.90,
      description:
          "Camiseta Estampada Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Camisetas",
      nameImage: "assets/images/camiseta.jpg",
      availableSizes: ["04", "05", "06"],
    ),
  ],
  "Shorts": [
    Product(
      id: 7,
      name: "Shorts Jeans",
      costPrice: 59.90,
      salePrice: 79.90,
      description:
          "Shorts Jeans Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Shorts",
      nameImage: "assets/images/categoria_shorts.jpg",
      availableSizes: ["04", "06", "08"],
    ),
    Product(
      id: 8,
      name: "Shorts de Algodão",
      costPrice: 49.90,
      salePrice: 99.90,
      description:
          "Shorts de Algodão Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Shorts",
      nameImage: "assets/images/short.jpg",
      availableSizes: ["06", "08", "10"],
    ),
  ],
  "Vestidos": [
    Product(
      id: 9,
      name: "Vestido Rendado",
      costPrice: 89.90,
      salePrice: 129.90,
      description:
          "Vestido Rendado Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Vestidos",
      nameImage: "assets/images/categoria_vestidos.jpg",
      availableSizes: ["04", "06"],
    ),
    Product(
      id: 10,
      name: "Vestido Bordô",
      costPrice: 79.90,
      salePrice: 119.90,
      description:
          "Vestido Bordô Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Vestidos",
      nameImage: "assets/images/vestido.jpg",
      availableSizes: ["06", "08"],
    ),
  ],
  "Praia": [
    Product(
      id: 11,
      name: "Maiô de Bolinhas",
      costPrice: 59.90,
      salePrice: 89.90,
      description:
          "Maiô de Bolinhas Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Praia",
      nameImage: "assets/images/categoria_praia.jpg",
      availableSizes: ["04", "06", "08", "10"],
    ),
    Product(
      id: 12,
      name: "Short de Banho",
      costPrice: 69.90,
      salePrice: 99.90,
      description:
          "Short de BAnho Infantil Luluzinha Kids, Confortável e Estilosa, Perfeita para o Dia a Dia das Crianças.",
      category: "Praia",
      nameImage: "assets/images/praia.jpg",
      availableSizes: ["08", "10", "12", "14"],
    ),
  ],
};
