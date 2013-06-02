class CustomFieldsRight < ActiveRecord::Base
  unloadable
  belongs_to :role
  belongs_to :issue_custom_field, inverse_of: :custom_fields_rights

  validates_presence_of :role_id, :rights, :issue_custom_field
end
