module RootInstanceMethods

  include InstanceMethods
  
  # Instantiates the instance as it's lowest root class. Used when destroying a root class to 
  # make sure we're not leaving children behind
  def as_child
    #instance_class = Object.const_get(self.type)
    return bottom_class_instance = self.class.where(:id => self.id).first
  end
  
  # Access the root class if ever you need.
  def as_root
     if self.class.superclass != ActiveRecord::Base
       root_class = self.class.superclass  

       #get to the root of it
       while root_class.superclass != ActiveRecord::Base
         root_class = root_class.superclass
       end

       #get the attributes of the class which are inherited from it's parent.
       attributes_for_parent = self.attributes.reject{|key,value| !root_class.column_names.include?(key) }

       #create a new instance of the superclass, passing the inherited attributes.
       parent = root_class.new(attributes_for_parent)
       parent.id = self.id
       parent.type = self.type
       
       parent.is_new_record(new_record?)

       parent
     else
        self #just return self if we are the root
     end
  end

end