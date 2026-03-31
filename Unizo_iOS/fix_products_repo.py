import re
filepath = "/Users/user57/Downloads/Unizo_iOS-91b34829bbcafc580c90ec82b20083c30b1c9c45/Unizo_iOS/Data/Repositories/ProductRepository.swift"
with open(filepath, 'r') as f:
    text = f.read()

# Replace exact variable name
text = text.replace("sellerId", "seller_id")

# Fix status comparison
text = text.replace('status != "sold"', 'status != .sold')
text = text.replace('status == "sold"', 'status == .sold')

# Fix DTO mappings for nested Seller
text = text.replace(
    'products[index].seller = user',
    'products[index].seller = ProductSellerDTO(id: user.id, first_name: user.first_name, last_name: user.last_name, email: user.email)'
)
text = text.replace(
    'product.seller = try? sellerDoc.data(as: UserDTO.self)',
    'if let u = try? sellerDoc.data(as: UserDTO.self) { product.seller = ProductSellerDTO(id: u.id, first_name: u.first_name, last_name: u.last_name, email: u.email) }'
)

with open(filepath, 'w') as f:
    f.write(text)
print("Updated Product Repository.")
