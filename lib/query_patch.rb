module CustomFieldsPermissions
  module QueryPatch
    module ClassMethods

    end

    module InstanceMethods
      def columns_with_custom_fields_rights
        columns_without_custom_fields_rights.delete_if { |c| c.is_a?(QueryCustomFieldColumn) ? !User.current.allowed_to?(:read, [c.custom_field, project]) : false }
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.class_eval do
        unloadable

        alias_method_chain :columns, :custom_fields_rights
      end
    end
  end
end
