module JsonResource
  module Model
    extend ActiveSupport::Concern
    
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON'].to_set
    
    included do
      class_attribute :attributes, :collections, :objects, :root_path, :inflection
      self.attributes = {}
      self.collections = {}
      self.objects = {}
      self.inflection = :lower_camelcase
    end
  
    module ClassMethods
      
      def from_json(obj, default_attrs = {})
        return unless json = parse(obj)
        json = json_dig(json, *root_path) if root_path
        attrs = {}
        self.attributes.each do |name, options|
          if path = attribute_path(name)
            value = json_dig(json, *path)
            if !value.nil? && type = attribute_type(name)
              value = cast_to(type, value)
            end
            attrs[name] = value
          end
        end
        instance = new(attrs.compact.reverse_merge(default_attrs))
        self.objects.each do |name, options|
          if path = object_path(name)
            instance.public_send("#{name}=", object_class(name).from_json(json_dig(json, *path)))
          end
        end
        self.collections.each do |name, options|
          if path = collection_path(name)
            instance.public_send("#{name}=", collection_class(name).collection_from_json(json_dig(json, *path)))
          end
        end
        instance
      end
    
      def collection_from_json(obj, default_attrs = {})
        json = parse(obj)
        json = json_dig(json, root) if root
        json.map { |hsh| from_json(hsh, default_attrs) }.compact
      end
    
      def basename
        name.sub(/^.*::/, '')
      end
    
      def root
        self.root_path
      end
    
      def root=(root)
        self.root_path = root
      end
    
      [:attribute, :object, :collection].each do |method_name|
        define_method "#{method_name}_names" do
          send(method_name.to_s.pluralize).keys
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
        define_method "#{method_name}_path" do |name|
          options = send(method_name.to_s.pluralize)
          Array(options[name].try(:[], :path)).presence || [inflect(name)]
        end
      end

      def attribute_type(name)
        attributes[name] && attributes[name][:type]
      end
    
      def object_class(name)
        if objects[name] && class_name = objects[name][:class_name]
          class_name.constantize
        else
          name.to_s.camelize.constantize
        end
      end
    
      def collection_class(name)
        if collections[name] && class_name = collections[name][:class_name]
          class_name.constantize
        else
          name.to_s.singularize.camelize.constantize
        end
      end
    
      def cast_to(type, value)  # only called for non-nil values
        case type
        when :string    then value
        when :integer   then value.to_i
        when :float     then value.to_f
        when :boolean   then cast_to_boolean(value)
        when :decimal   then BigDecimal(value)
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
      @attributes ||= {}.with_indifferent_access
    end
  
    def [](attr_name)
      attributes[attr_name]
    end
  
    def []=(attr_name, value)
      attributes[attr_name] = value
    end
  
  end
end
