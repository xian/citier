class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :type
      t.string :name
      t.integer :price

      t.timestamps
      create_citier_view(Product)
    end
  end

  def self.down
    drop_citier_view(Product)
    drop_table :products
  end
end
