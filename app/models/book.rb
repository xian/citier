class Book < Product
  acts_as_citier
  validates_presence_of :title
  
  def an_awesome_book
    self.an_awesome_product
    puts "A book to be precise"
  end
end
