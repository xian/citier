class Book < Product
  acts_as_citier
  validates_presence_of :title
end
