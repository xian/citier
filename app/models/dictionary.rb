class Dictionary < Book
  acts_as_citier
  validates_presence_of :language
end
