module IssuePatch
  module ClassMethods

  end

  module InstanceMethods
    def editable_custom_field_values_with_custom_fields_rights(user=nil)
      editable_custom_field_values_without_custom_fields_rights(user).select do |value|
        if value.custom_field.type == 'IssueCustomField'
          user ||= User.current
          user.allowed_to?(:write, [value.custom_field, project])
        else
          true
        end
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods

    receiver.class_eval do
      unloadable

      alias_method_chain :editable_custom_field_values, :custom_fields_rights
    end
  end
end
