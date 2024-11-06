module JsonResource
  module Refinements

    refine Object do

      def blank?
        respond_to?(:empty?) ? !!empty? : !self
      end

      def present?
        !blank?
      end

      def presence
        self if present?
      end
      
      def try(*a, &b)
        try!(*a, &b) if a.empty? || respond_to?(a.first)
      end

      def try!(*a, &b)
        if a.empty? && block_given?
          if b.arity == 0
            instance_eval(&b)
          else
            yield self
          end
        else
          public_send(*a, &b)
        end
      end

    end

    refine NilClass do

      def try(*args)
        nil
      end

      def try!(*args)
        nil
      end

    end

    refine Class do

      def class_attribute(*attrs)
        attrs.each do |name|
          define_singleton_method(name) { nil }

          ivar = "@#{name}"

          define_singleton_method("#{name}=") do |val|
            singleton_class.class_eval do
              undef_method(name) if method_defined?(name) || private_method_defined?(name)
              define_method(name) { val }
            end

            if singleton_class?
              class_eval do
                undef_method(name) if method_defined?(name) || private_method_defined?(name)
                define_method(name) do
                  if instance_variable_defined? ivar
                    instance_variable_get ivar
                  else
                    singleton_class.send name
                  end
                end
              end
            end
            val
          end

          undef_method(name) if method_defined?(name) || private_method_defined?(name)
          define_method(name) do
            if instance_variable_defined?(ivar)
              instance_variable_get ivar
            else
              self.class.public_send name
            end
          end

          attr_writer name
        end
      end

    end
    
    refine String do

      def constantize
        if blank? || !include?("::")
          Object.const_get(self)
        else
          names = split("::")

          # Trigger a built-in NameError exception including the ill-formed constant in the message.
          Object.const_get(self) if names.empty?

          # Remove the first blank element in case of '::ClassName' notation.
          names.shift if names.size > 1 && names.first.empty?

          names.inject(Object) do |constant, name|
            if constant == Object
              constant.const_get(name)
            else
              candidate = constant.const_get(name)
              next candidate if constant.const_defined?(name, false)
              next candidate unless Object.const_defined?(name)

              # Go down the ancestors to check if it is owned directly. The check
              # stops when we reach Object or the end of ancestors tree.
              constant = constant.ancestors.inject(constant) do |const, ancestor|
                break const    if ancestor == Object
                break ancestor if ancestor.const_defined?(name, false)
                const
              end

              # owner is in Object, so raise
              constant.const_get(name, false)
            end
          end
        end
      end

      def camelcase(*separators)
        case separators.first
        when Symbol, TrueClass, FalseClass, NilClass
          first_letter = separators.shift
        end

        separators = ['_', '\s'] if separators.empty?

        str = self.dup

        separators.each do |s|
          str = str.gsub(/(?:#{s}+)([a-z])/){ $1.upcase }
        end

        case first_letter
        when :upper, true
          str = str.gsub(/(\A|\s)([a-z])/){ $1 + $2.upcase }
        when :lower, false
          str = str.gsub(/(\A|\s)([A-Z])/){ $1 + $2.downcase }
        end

        str
      end

      def underscore
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr('-', '_').
        gsub(/\s/, '_').
        gsub(/__+/, '_').
        downcase
      end

      def dasherize
        underscore.gsub('_', '-')
      end

      def pluralize
        return dup if Inflections.uncountables.reverse.any? { |suffix| end_with?(suffix) }
        Inflections.irregulars.reverse.each do |suffix, irregluar|
          return sub(/#{Regexp.escape(suffix)}\z/, irregluar) if end_with?(suffix)
        end
        plural = dup
        Inflections.pluralizations.reverse.each do |pattern, substitution|
          return plural if plural.gsub!(pattern, substitution)
        end
        plural
      end

      def singularize
        return dup if Inflections.uncountables.reverse.any? { |suffix| end_with?(suffix) }
        Inflections.irregulars.reverse.each do |suffix, irregular|
          return sub(/#{Regexp.escape(irregular)}\z/, suffix) if end_with?(irregular)
        end
        singular = dup
        Inflections.singularizations.reverse.each do |pattern, substitution|
          return singular if singular.gsub!(pattern, substitution)
        end
        singular
      end

      def camelize
        camelcase(:upper)
      end

      def classify
        sub(/.*\./, '').singularize.camelize
      end

    end

    refine Hash do

      def symbolize_keys
        transform_keys(&:to_sym)
      end

    end

    refine Array do

      def extract_options!
        if last.is_a?(Hash) && last.instance_of?(Hash)
          pop
        else
          {}
        end
      end

    end

  end
end
