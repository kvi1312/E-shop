class CreateAdminStocks < ActiveRecord::Migration[7.2]
  def change
    create_table :stocks do |t|
      t.integer :size
      t.integer :amount
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
