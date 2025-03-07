# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
admin = Admin.find_or_initialize_by(email: "lenguyenkhai2611@gmail.com")
admin.password = "123456"
admin.password_confirmation = "123456"
admin.save!

# Clear existing data
Stock.destroy_all
Product.destroy_all
Category.destroy_all
puts "Deleted all existing stocks, products, and categories"

# Create categories with respective images
categories = [
  {
    name: "Women",
    description: "Women's clothing and apparel",
    image_filename: "Women.jpg"
  },
  {
    name: "Men",
    description: "Men's clothing and apparel",
    image_filename: "Men.jpg"
  },
  {
    name: "Shoe",
    description: "Footwear collection for all styles",
    image_filename: "Shoe.jpg"
  },
  {
    name: "Accessory",
    description: "Fashion accessories to complete your look",
    image_filename: "Accessory.jpg"
  }
]

# Hash to store created categories for later reference
created_categories = {}

# Create each category and attach the image
categories.each do |category_data|
  category = Category.create!(
    name: category_data[:name],
    description: category_data[:description]
  )
  
  # Store in hash for later use
  created_categories[category_data[:name]] = category

  # Path to the image file - trying different possible locations
  possible_paths = [
    Rails.root.join('public', 'Category', category_data[:image_filename]),
    Rails.root.join('app', 'public', 'Category', category_data[:image_filename]),
    Rails.root.join('app', 'assets', 'images', 'Category', category_data[:image_filename]),
    Rails.root.join('storage', 'Category', category_data[:image_filename])
  ]

  # Find the first path that exists
  image_path = possible_paths.find { |path| File.exist?(path) }

  # Attach the image if file exists
  if image_path
    category.image.attach(
      io: File.open(image_path),
      filename: category_data[:image_filename],
      content_type: category_data[:image_filename].end_with?('png') ? "image/png" : "image/jpeg"
    )
    puts "Created category: #{category.name} with image: #{image_path}"
  else
    puts "Warning: Image file not found for category: #{category.name}"
    puts "Searched in the following locations:"
    possible_paths.each { |path| puts "  - #{path}" }
  end
end

puts "Created #{Category.count} categories"

# Define products and their category
products_data = {
  "Accessory" => [
    { name: "Gucci Bag", description: "Luxury Gucci bag", price: 1500, active: true, image_filename: "Bag-Gucci.png" },
    { name: "Louis Vuitton Bag", description: "Elegant LV bag", price: 1800, active: true, image_filename: "Bag-LV.png" },
    { name: "Gucci Belt", description: "Designer Gucci belt", price: 450, active: true, image_filename: "Belt-Gucci.png" },
    { name: "Rolex Watch", description: "Premium Rolex timepiece", price: 8500, active: true, image_filename: "Watch-Rolex.png" }
  ],
  "Men" => [
    { name: "Gucci T-Shirt", description: "Men's Gucci T-shirt", price: 550, active: true, image_filename: "Gucci.png" },
    { name: "Off-White Hoodie", description: "Men's Off-White hoodie", price: 650, active: true, image_filename: "Off-White.png" },
    { name: "Vlone T-Shirt", description: "Men's Vlone T-shirt", price: 320, active: true, image_filename: "Vlone.png" }
  ],
  "Shoe" => [
    { name: "Adidas Sneakers", description: "Comfortable Adidas sneakers", price: 120, active: true, image_filename: "Adidas.png" },
    { name: "Converse Classic", description: "Classic Converse shoes", price: 80, active: true, image_filename: "Converse.png" },
    { name: "New Balance Running", description: "New Balance running shoes", price: 110, active: true, image_filename: "NewBalance.png" },
    { name: "Nike Air Max", description: "Nike Air Max sneakers", price: 150, active: true, image_filename: "Nike.png" },
    { name: "Vans Skate", description: "Vans skateboarding shoes", price: 75, active: true, image_filename: "Vans.png" }
  ],
  "Women" => [
    { name: "Supreme Hoodie", description: "Women's Supreme hoodie", price: 580, active: true, image_filename: "Women-Hoddie-Supreme.png" },
    { name: "Off-White Dress", description: "Women's Off-White dress", price: 890, active: true, image_filename: "Women-OffWhite.png" }
  ]
}

# Create products for each category
products_data.each do |category_name, products|
  category = created_categories[category_name]
  
  if category.nil?
    puts "Warning: Category '#{category_name}' not found"
    next
  end
  
  products.each do |product_data|
    product = Product.create!(
      name: product_data[:name],
      description: product_data[:description],
      price: product_data[:price],
      active: product_data[:active],
      category: category
    )
    
    # Path to the product image
    possible_paths = [
      Rails.root.join('public', 'Product', category_name, product_data[:image_filename]),
      Rails.root.join('app', 'public', 'Product', category_name, product_data[:image_filename]),
      Rails.root.join('app', 'assets', 'images', 'Product', category_name, product_data[:image_filename]),
      Rails.root.join('storage', 'Product', category_name, product_data[:image_filename])
    ]
    
    # Find the first path that exists
    image_path = possible_paths.find { |path| File.exist?(path) }
    
    # Attach the image if file exists
    if image_path
      product.images.attach(
        io: File.open(image_path),
        filename: product_data[:image_filename],
        content_type: "image/png"
      )
      puts "Created product: #{product.name} with image: #{image_path}"
    else
      puts "Warning: Image file not found for product: #{product.name}"
      puts "Searched in the following locations:"
      possible_paths.each { |path| puts "  - #{path}" }
    end
    
    # Create stock entries for sizes 37-40 with 50 items each
    (37..40).each do |size|
      Stock.create!(
        size: size,
        amount: 50,
        product: product
      )
      puts "Added stock for #{product.name}: Size #{size} - 50 items"
    end
  end
end

puts "Created #{Product.count} products with #{Stock.count} stock entries"