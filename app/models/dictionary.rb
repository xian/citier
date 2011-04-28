class Dictionary < Book
  acts_as_citier
  validates_presence_of :language
  
  def is_awesome
    self.an_awesome_book
    puts "I am a dictionary. Yeah!"
  end
end
