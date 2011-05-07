class CreateBooks < ActiveRecord::Migration
  def self.up
    # When you create the book table, it needs to use the auto-inc'd
    # key from the products table, not generate it's own, otherwise
    # the book id could go up by 1, but the product id has since gone
    # by 3 due to other children of 'product' class. Therefore Id's
    # won't match. 'id' still set as primary key, but not auto inc'd
    create_table :books do |t|
      t.string :title
      t.string :author
    end
    create_citier_view(Book)
  end

  def self.down
    drop_citier_view(Book)
    drop_table :books
  end
end
