module UserPatch
  module ClassMethods

  end

  module InstanceMethods
    def allowed_to_with_issue_custom_field?(action, context, options={}, &block)
      if context && context.is_a?(Array) && context.size == 2 && context.first.is_a?(IssueCustomField) && context.last.is_a?(Project)
        custom_field = context.first
        project = context.last
        return false unless custom_field.allows_to?(action)
        # Admin users are authorized for anything else
        return true if admin?

        roles = roles_for_project(project)
        return false unless roles
        roles.any? do |role|
          custom_field.allows_to?(action, role)
        end
      else
        allowed_to_without_issue_custom_field?(action, context, options, &block)
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods

    receiver.class_eval do
      unloadable

      alias_method_chain :allowed_to?, :issue_custom_field
    end
  end
end
