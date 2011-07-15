module InstanceMethods

  # Delete the model (and all parents it inherits from if applicable)
  def delete(id = self.id)
    citier_debug("Deleting #{self.class.to_s} with ID #{self.id}")

    # Delete information stored in the table associated to the class of the object
    # (if there is such a table)
    deleted = true
    c = self.class
    
    # We're either deleting the root class or an instance.
    
    if c.superclass==ActiveRecord::Base
      # 1 #### we're deleting the root so delete down the heirachy to make sure we leave no stragglers.
      
      #delete it's children
      if self.type != self.class.to_s
        citier_debug("Deleting Child Class Instance #{self} from bottom class with ID #{self.id}")
        self.as_child.destroy #Will loop back through this method but take the below root instead  
      else
        super() #just call our super deleted method
      end
      
    else
      # 2 #### we're deleting a child so delete up the hierachy to leave no trace.
      
      while c.superclass!=ActiveRecord::Base
        citier_debug("Deleting back up hierarchy #{c}")
        deleted &= c::Writable.delete(id)
        c = c.superclass
      end
    
      deleted &= c.delete(id)
      return deleted
      
    end
    
  end

  def updatetype        
    sql = "UPDATE #{self.class.root_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
    self.connection.execute(sql)
    citier_debug("#{sql}")
  end

  def destroy
    return self.delete
  end
  
  # USAGE validates :attribute, :citier_uniqueness => true
  # Needed because validates :attribute, :uniqueness => true  Won't work because it tries to call child_class.attribute on parents table
  class CitierUniquenessValidator < ActiveModel::EachValidator  
    def validate_each(object, attribute, value)
      existing_record = object.class.where(attribute.to_sym => value).limit(1).first
      if existing_record && existing_record != object #if prev record exist and it isn't our current obj
            object.errors[attribute] << (options[:message] || "has already been taken.")  
      end 
    end  
  end

end