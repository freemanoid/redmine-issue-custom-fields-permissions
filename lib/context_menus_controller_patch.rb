module CustomFieldsPermissions
  module ContextMenusControllerPatch
    module ClassMethods

    end

    module InstanceMethods
      def issues_with_custom_fields_rights
        @issues = Issue.visible.all(:conditions => {:id => params[:ids]}, :include => :project)
      if (@issues.size == 1)
        @issue = @issues.first
      end
      @issue_ids = @issues.map(&:id).sort

      @allowed_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)
      @projects = @issues.collect(&:project).compact.uniq
      @project = @projects.first if @projects.size == 1

      @can = {:edit => User.current.allowed_to?(:edit_issues, @projects),
              :log_time => (@project && User.current.allowed_to?(:log_time, @project)),
              :update => (User.current.allowed_to?(:edit_issues, @projects) || (User.current.allowed_to?(:change_status, @projects) && !@allowed_statuses.blank?)),
              :move => (@project && User.current.allowed_to?(:move_issues, @project)),
              :copy => (@issue && @project.trackers.include?(@issue.tracker) && User.current.allowed_to?(:add_issues, @project)),
              :delete => User.current.allowed_to?(:delete_issues, @projects)
              }
      if @project
        if @issue
          @assignables = @issue.assignable_users
        else
          @assignables = @project.assignable_users
        end
        @trackers = @project.trackers
      else
        #when multiple projects, we only keep the intersection of each set
        @assignables = @projects.map(&:assignable_users).reduce(:&)
        @trackers = @projects.map(&:trackers).reduce(:&)
      end
      @versions = @projects.map {|p| p.shared_versions.open}.reduce(:&)

      @priorities = IssuePriority.active.reverse
      @back = back_url

      @options_by_custom_field = {}
      if @can[:edit]
        custom_fields = @issues.map(&:available_custom_fields).reduce(:&).select do |f|
          %w(bool list user version).include?(f.field_format) && !f.multiple?
        end
        custom_fields.each do |field|
          values = field.possible_values_options(@projects)
          if values.any?
            @options_by_custom_field[field] = values
          end
        end
      end

      @options_by_custom_field = @options_by_custom_field.keep_if { |k, v| User.current.allowed_to?(:edit, [k, @project]) }

      @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)
      render :layout => false
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.class_eval do
        unloadable

        alias_method_chain :issues, :custom_fields_rights
      end
    end
  end
end
