class Product < ActiveRecord::Base
  acts_as_citier
  validates_presence_of :name
end
