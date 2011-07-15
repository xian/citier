module RootInstanceMethods

  include InstanceMethods
  
  # Instantiates the instance as it's lowest root class. Used when destroying a root class to 
  # make sure we're not leaving children behind
  def as_child
    #instance_class = Object.const_get(self.type)
    return bottom_class_instance = self.class.where(:id => self.id).first
  end

end