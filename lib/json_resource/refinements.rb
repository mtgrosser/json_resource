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
      
      include Inflections
      
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
      
    end
    
    refine Hash do
      
      def symbolize_keys
        transform_keys(&:to_sym)
      end
      
    end

  end
end
