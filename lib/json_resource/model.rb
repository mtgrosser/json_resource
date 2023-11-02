module JsonResource
  using JsonResource::Refinements

  module Model
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON'].to_set
    BIGDECIMAL_PRECISION = 18
    
    def self.included(base)
      base.extend ClassMethods
      base.class_attribute :attributes, :collections, :objects, :inflection
      base.attributes = {}
      base.collections = {}
      base.objects = {}
      base.inflection = :lower_camelcase
    end

    module ClassMethods
      
      def from_json(obj, defaults: {}, root: nil)
        return unless json = parse(obj)
        json = json_dig(json, *root) if root
        attrs = {}
        self.attributes.each do |name, options|
          if path = attribute_path(name)
            value = json_dig(json, *path)
            if !value.nil? && type = attribute_type(name)
              value = cast_to(type, value, name)
            end
            attrs[name] = value
          end
        end
        instance = new(defaults.merge(attrs.compact))
        self.objects.each do |name, options|
          if path = object_path(name) and obj = json_dig(json, *path)
            instance.public_send("#{name}=", object_class(name).from_json(obj))
          end
        end
        self.collections.each do |name, options|
          collection = if path = collection_path(name) and obj = json_dig(json, *path)
            instance.public_send("#{name}=", collection_class(name).collection_from_json(obj))
          else
            []
          end
        end
        instance
      end
    
      def collection_from_json(obj, defaults: {}, root: nil)
        json = parse(obj)
        json = json_dig(json, *root) if root
        json.map { |hsh| from_json(hsh, defaults: defaults) }.compact
      end
    
      def basename
        name.sub(/^.*::/, '')
      end
    
      [:attribute, :object, :collection].each do |method_name|
        define_method "#{method_name}_names" do
          send("#{method_name}s").keys
        end
      end
    
      protected
    
      def attribute(name, options = {})
        self.attributes = attributes.merge(name.to_sym => options.symbolize_keys)
        attribute_accessor_method name
      end
    
      def attributes(*args)
        options = args.extract_options!
        args.each { |arg| has_attribute arg, options }
      end
    
      def has_object(name, options = {})
        self.objects = objects.merge(name.to_sym => options.symbolize_keys)
        attr_accessor name
      end
    
      def has_collection(name, options = {})
        self.collections = collections.merge(name.to_sym => options.symbolize_keys)
        define_method "#{name}" do
          instance_variable_get("@#{name}") or instance_variable_set("@#{name}", [])
        end
        define_method "#{name}=" do |assignment|
          instance_variable_set("@#{name}", assignment) if assignment
        end
      end

      private
    
      def attribute_accessor_method(name)
        define_method("#{name}") { self[name] }
        define_method("#{name}=") { |value| self[name] = value }
      end

      [:attribute, :object, :collection].each do |method_name|
        define_method "#{method_name}_options" do |name|
          send(method_name.to_s.pluralize).try(:[], name)
        end
        
        define_method "#{method_name}_path" do |name|
          options = send("#{method_name}_options", name)
          Array(options.try(:[], :path)).presence || [inflect(name)]
        end
      end

      def attribute_type(name)
        attributes[name] && attributes[name][:type]
      end
      
      def object_class(name)
        if objects[name] && class_name = objects[name][:class_name]
          class_name.constantize
        else
          name.to_s.classify.constantize
        end
      end
    
      def collection_class(name)
        if collections[name] && class_name = collections[name][:class_name]
          class_name.constantize
        else
          name.to_s.singularize.classify.constantize
        end
      end
    
      def cast_to(type, value, name)  # only called for non-nil values
        case type
        when :string    then value
        when :integer   then value.to_i
        when :float     then value.to_f
        when :boolean   then cast_to_boolean(value)
        when :decimal   then cast_to_big_decimal(value, **attribute_options(name))
        when :date      then value.presence && Date.parse(value)
        when :time      then value.presence && Time.parse(value)
        else
          raise JsonResource::TypeCastError, "don't know how to cast #{value.inspect} to #{type}"
        end
      end

      def cast_to_boolean(value)
        if value.is_a?(String) && value.blank?
          nil
        else
          TRUE_VALUES.include?(value)
        end
      end
      
      def cast_to_big_decimal(value, scale: nil, precision: nil, **)
        cast_value = case value
        when ::Float
          precision ||= BIGDECIMAL_PRECISION
          float_precision = precision.to_i > ::Float::DIG + 1 ? ::Float::DIG + 1 : precision.to_i
          BigDecimal(value, float_precision)
        when ::Numeric
          BigDecimal(value, precision || BIGDECIMAL_PRECISION)
        when ::String
          begin
            value.to_d
          rescue ArgumentError
            BigDecimal(0)
          end
        else
          value.respond_to?(:to_d) ? value.to_d : BigDecimal(value.to_s)
        end
        scale ? cast_value.round(scale) : cast_value
      end

      def parse(obj)
        case obj
        when Hash, Array then obj
        when String then JSON.parse(obj)
        else
          raise JsonResource::ParseError, "cannot parse #{obj.inspect}"
        end 
      end
      
      def inflect(string)
        string = string.to_s
        case inflection
        when :lower_camelcase
          string.camelcase(:lower)
        when :upper_camelcase
          string.camelcase(:upper)
        when :dasherize
          string.underscore.dasherize
        when nil
          string.underscore
        else
          string.public_send(inflection)
        end
      end
      
      def json_dig(obj, *path)
        path.inject(obj) do |receiver, key|
          next nil if receiver.nil?
          if key.respond_to?(:match) and idx = key.match(/\A\[(?<idx>\d+)\]\z/).try(:[], :idx)
            receiver[idx.to_i]
          else
            receiver[key]
          end
        end
      end
    end
  
    def initialize(attrs = {})
      self.attributes = attrs if attrs
      super()
    end

    def valid?
      true
    end
  
    def attributes=(attrs)
      attrs.each do |attr, value|
        self.public_send("#{attr}=", value)
      end
    end
  
    def attributes
      @attributes ||= {}
    end
  
    def [](attr_name)
      attributes[attr_name.to_sym]
    end
  
    def []=(attr_name, value)
      attributes[attr_name.to_sym] = value
    end
  
  end
end
