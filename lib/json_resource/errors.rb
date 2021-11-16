module JsonResource
  class Error < StandardError; end
  class ParseError < Error; end
  class TypeCastError < Error; end
end
