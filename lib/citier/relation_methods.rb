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
        
        bind_values.each do |bind_value|
          if bind_value[0].name == "id"
            ids = bind_value[1]
            break
          end
        end
        ids ||= where_values_hash["id"] || where_values_hash[:id]
        where_hash = ids ? { :id => ids } : nil
        
        deleted &= c.base_class.where(where_hash).relation_delete_all
        while c.superclass != ActiveRecord::Base
          if c.const_defined?(:Writable)
            citier_debug("Deleting back up hierarchy #{c}")
            deleted &= c::Writable.where(where_hash).delete_all
          end
          c = c.superclass
        end
        deleted
      end
    end

  end
end