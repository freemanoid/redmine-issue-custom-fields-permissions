module CustomFieldsPermissions
  module IssuesHelperPatch
    module ClassMethods

    end

    module InstanceMethods
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.class_eval do
        unloadable

        def render_custom_fields_rows(issue)
          custom_field_values = issue.custom_field_values
          custom_field_values.select! { |f| User.current.allowed_to?(:read, [f.custom_field, issue.project]) }
          return if issue.custom_field_values.empty?
          ordered_values = []
          half = (issue.custom_field_values.size / 2.0).ceil
          half.times do |i|
            ordered_values << issue.custom_field_values[i]
            ordered_values << issue.custom_field_values[i + half]
          end
          s = "<tr>\n"
          n = 0
          ordered_values.compact.each do |value|
            s << "</tr>\n<tr>\n" if n > 0 && (n % 2) == 0
            s << "\t<th>#{ h(value.custom_field.name) }:</th><td>#{ simple_format_without_paragraph(h(show_value(value))) }</td>\n"
            n += 1
          end
          s << "</tr>\n"
          s.html_safe
        end
      end
    end
  end
end
