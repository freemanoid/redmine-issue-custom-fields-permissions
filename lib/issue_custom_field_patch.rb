require_dependency 'issue_custom_field'

module CustomFieldsPermissions
  module IssueCustomFieldPatch
    def self.included(base)
      base.extend         ClassMethods
      base.send :include, InstanceMethods

      base.class_eval do
        unloadable
        has_many :custom_fields_rights, inverse_of: :issue_custom_field, dependent: :destroy
        accepts_nested_attributes_for :custom_fields_rights
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      def allows_to?(action, role = nil)
        if role # If allows this action for role.
          return false unless allows_to?(action)
          rights = custom_fields_rights.where(role_id: role.id)
          if rights.present?
            rights = rights.first.rights
            permited_actions = []
            permited_actions << :read if rights > 0
            permited_actions << :write << :edit if rights > 1
            if action.is_a?(Symbol)
              permited_actions.include?(action)
            elsif action.is_a?(Array)
              action.map { |action| permited_actions.include?(action) }.reduce(:&)
            else
              false
            end
          else
            false
          end
        else # If allows this action at least for some role.
          if action.is_a?(Array)
            action.map { |action| allows_to?(action) }.reduce(:&)
          elsif action.is_a?(Symbol)
            [:read, :write, :edit].include?(action)
          else
            false
          end
        end
      end
    end
  end
end
