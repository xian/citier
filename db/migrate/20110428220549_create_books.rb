class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string, :title
      t.string :author
    end
    create_citier_view(Book)
  end

  def self.down
    drop_citier_view(Book)
    drop_table :books
  end
end
