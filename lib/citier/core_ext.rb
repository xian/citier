class ActiveRecord::Base 
  
  def self.set_acts_as_citier(citier)
    @acts_as_citier = citier
  end
  
  def self.acts_as_citier?
    @acts_as_citier || false
  end

  def self.[](column_name) 
    arel_table[column_name]
  end

  def is_new_record(state)
    @new_record = state
  end

  def self.create_class_writable(class_reference)  #creation of a new class which inherits from ActiveRecord::Base
    Class.new(ActiveRecord::Base) do
      include Citier::InstanceMethods::ForcedWriters
      
      t_name = class_reference.table_name
      t_name = t_name[5..t_name.length]

      if t_name[0..5] == "view_"
        t_name = t_name[5..t_name.length]
      end

      # set the name of the table associated to this class
      # this class will be associated to the writable table of the class_reference class
      set_table_name(t_name)
    end
  end
end
