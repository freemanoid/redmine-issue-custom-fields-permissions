require 'redmine'

Rails.configuration.to_prepare do
  require 'issue_custom_field_patch'
  IssueCustomField.send :include, IssueCustomFieldPatch
  require 'role_patch'
  Role.send             :include, RolePatch
  require 'custom_fields_controller_patch'
  CustomFieldsController.send :include, CustomFieldsControllerPatch
  require 'user_patch'
  User.send             :include, UserPatch
  require 'issues_helper_patch'
  IssuesHelper.send     :include, IssuesHelperPatch
  require 'issue_patch'
  Issue.send     :include, IssuePatch
end

class ViewsHooks < Redmine::Hook::ViewListener
  render_on :view_custom_fields_form_issue_custom_field, :partial => "custom_fields/role_access"
end


Redmine::Plugin.register :issue_custom_fields_rights do
  name 'Issue custom fields rights plugin'
  author 'Alexandr Elhovenko'
  description 'Add read/write access settings for each role for each issue custom field.'
  version '0.1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'alexandr.elhovenko@gmail.com'
end
