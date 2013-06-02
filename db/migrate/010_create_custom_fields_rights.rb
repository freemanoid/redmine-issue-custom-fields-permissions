class CreateCustomFieldsRights < ActiveRecord::Migration
  def change
    create_table :custom_fields_rights do |t|
      t.references :role
      t.references :issue_custom_field
      t.integer :rights, default: 0
    end
    # Add denied rights for all roles for all issue custom fields.
    say_with_time 'Add denied rights for all roles for all IssueCustomField.' do
      Role.givable.each do |role|
        IssueCustomField.all.each do |cf|
          cf.custom_fields_rights.create(role: role, rights: 0)
        end
      end
    end
  end
end
