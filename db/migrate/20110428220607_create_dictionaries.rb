class CreateDictionaries < ActiveRecord::Migration
  def self.up
    create_table :dictionaries, :id => false do |t|
      t.integer :id, :options => 'PRIMARY KEY'
      t.string :language
    end
    create_citier_view(Dictionary)
  end

  def self.down
    drop_citier_view(Dictionary)
    drop_table :dictionaries
  end
end
