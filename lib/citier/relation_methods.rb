module ActiveRecord
  class Relation
    
    alias_method :relation_delete_all, :delete_all
    def delete_all(conditions = nil)
      if conditions
        relation_delete_all(conditions)
      else
        deleted = true
        ids = nil
        c = @klass
        ids = where_values_hash[:id]
        deleted &= c.base_class.where(:id => ids).relation_delete_all
        while c.superclass!=ActiveRecord::Base
          if c.const_defined?(:Writable)
            citier_debug("Deleting back up hierarchy #{c}")
            deleted &= c::Writable.where(:id => ids).delete_all
          end
          c = c.superclass
        end
        deleted
      end
    end

  end
end