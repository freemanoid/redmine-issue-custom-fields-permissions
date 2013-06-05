module CustomFieldsPermissions
  module CustomFieldsControllerPatch
    module ClassMethods

    end

    module InstanceMethods

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.class_eval do
        unloadable
      end
    end
  end
end
