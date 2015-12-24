require 'active_support/concern'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'weka/concerns'

module Weka
  module ClassBuilder
    extend ActiveSupport::Concern

    module ClassMethods

      def build_class(class_name, weka_module: nil, include_concerns: true)
        java_import java_class_path(class_name, weka_module)
        define_class(class_name, include_concerns: include_concerns)
      end

      def build_classes(*class_names, weka_module: nil, include_concerns: true)
        class_names.each do |name|
          build_class(name, weka_module: weka_module, include_concerns: include_concerns)
        end
      end

      private

      def java_class_path(class_name, weka_module)
        if weka_module
          "#{weka_module}.#{class_name}"
        else
          [*java_super_modules, java_including_module, class_name].compact.join('.')
        end
      end

      def java_super_modules
        super_modules.split('::').map do |name|
          downcase_first_char(name)
        end
      end

      def super_modules
        toplevel_module? ? self.name : self.name.deconstantize
      end

      def java_including_module
        downcase_first_char(including_module)
      end

      def including_module
        self.name.demodulize unless toplevel_module?
      end

      def toplevel_module?
        self.name.scan('::').count == 1
      end

      def define_class(class_name, include_concerns: true)
        module_eval <<-CLASS_DEFINITION, __FILE__, __LINE__ + 1
          class #{class_name}
            #{'include Concerns' if include_concerns}
            #{include_utils}
          end
        CLASS_DEFINITION
      end

      def include_utils
        return unless utils_defined?
        "include #{utils}"
      end

      def utils_defined?
        utils_super_modules.constantize.const_defined?(:Utils)
      end

      def utils
        "::#{utils_super_modules}::Utils"
      end

      def utils_super_modules
        super_modules.split('::')[0..1].join('::')
      end

      def downcase_first_char(string)
        return if string.blank?
        string[0].downcase + string[1..-1]
      end
    end

  end
end
