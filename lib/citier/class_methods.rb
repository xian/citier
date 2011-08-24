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

        # Add the functions required for children only
        send :include, Citier::ChildInstanceMethods
      else
      # Root class

        after_save :updatetype

        citier_debug("Root Class")

        set_table_name "#{table_name}"

        citier_debug("table_name -> #{self.table_name}")

        def self.find(*args) #overrides find to get all attributes

          tuples = super

          # in case of many objects, return an array of them, reloaded to pull in inherited attributes
          return tuples.map{|x| x.reload} if tuples.kind_of?(Array)

          # in case of only one tuple, return it reloaded.
          # Can't use reload as would loop inifinitely, so do a search by id instead.
          # Probably a nice way of cleaning this a bit
          return tuples.class.where(tuples.class[:id].eq(tuples.id))[0]
        end

        # Add the functions required for root classes only
        send :include, Citier::RootInstanceMethods
      end
    end
  end
end