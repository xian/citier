module Citier
  module ClassMethods
    # any method placed here will apply to classes
    def acts_as_citier(options = {})

      # Option for setting the inheritance columns, default value = 'type'
      db_type_field = (options[:db_type_field] || :type).to_s

      #:table_name = option for setting the name of the current class table_name, default value = 'tableized(current class name)'
      table_name = (options[:table_name] || self.name.tableize.gsub(/\//,'_')).to_s

      set_inheritance_column "#{db_type_field}"

      if(self.superclass!=ActiveRecord::Base)
        # Non root-class

        citier_debug("Non Root Class")
        citier_debug("table_name -> #{table_name}")

        # Set up the table which contains ALL attributes we want for this class
        set_table_name "view_#{table_name}"

        citier_debug("tablename (view) -> #{self.table_name}")

        # The the Writable. References the write-able table for the class because
        # save operations etc can't take place on the views
        self.const_set("Writable", create_class_writable(self))
        
        after_initialize do
          self.id = nil if self.new_record? && self.id == 0
        end

        # Add the functions required for children only
        send :include, Citier::ChildInstanceMethods
      else
      # Root class

        citier_debug("Root Class")

        set_table_name "#{table_name}"

        citier_debug("table_name -> #{self.table_name}")

        def self.find(*args) #overrides find to get all attributes
          # With option :no_children set to true, only records of type self will be returned. 
          # So Root.all(:no_children => true) won't return Child records.
          options = args.last.is_a?(Hash) ? args.last : {}
          no_children = options.delete(:no_children)
          self_type = self.superclass == ActiveRecord::Base ? nil : self.name
          return self.where(:type => self_type).find(*args) if no_children
          
          tuples = super
          
          # If the tuple is already of this class's type, we don't need to reload it.
          return tuples if tuples.kind_of?(Array) ? tuples.all? { |tuple| tuple.class == self } : (tuples.class == self) 
          
          # In case of multiple tuples, find the correct ones using one query per type.
          if tuples.kind_of?(Array)
            found_records = []
            ids_wanted = {}
            
            # Map all the ids wanted per type
            tuples.each do |tuple|
              if tuple.class == self # We don't need to find the record again if this is already the correct one
                found_records << tuple
                next
              end
              
              type_ids_wanted = ids_wanted[tuple.class]
              type_ids_wanted ||= ids_wanted[tuple.class] = []
              type_ids_wanted << tuple.id
            end
            
            # Find all wanted records
            ids_wanted.each do |type, ids|
              found_records.push(*type.find(ids))
            end
            
            # Make a new array with the found records at the right places
            reloaded_tuples = []
            tuples.each do |tuple|
              reloaded_tuples << found_records.find { |found| found.id == tuple.id }
            end
            
            return reloaded_tuples
          end

          # In case of only one tuple, return it reloaded.
          return tuples.reload
        end

        # Add the functions required for root classes only
        send :include, Citier::RootInstanceMethods
      end
    end
  end
end