module CustomFieldsPermissions
  module RolePatch
    module ClassMethods

    end

    module InstanceMethods

    private
      def update_custom_fields_rights
        IssueCustomField.all.each do |cf|
          custom_fields_rights.create(issue_custom_field: cf)
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.class_eval do
        unloadable
        has_many :custom_fields_rights, dependent: :destroy
        after_create :update_custom_fields_rights
      end
    end
  end
end
