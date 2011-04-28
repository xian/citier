class Product < ActiveRecord::Base
  acts_as_citier
  validates_presence_of :name
  
  def an_awesome_product
    puts "I #{name} am an awesome product"
  end
end
