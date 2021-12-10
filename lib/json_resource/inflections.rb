module JsonResource
  module Inflections
    
    class << self
      attr_accessor :pluralizations, :singularizations, :irregulars, :uncountables, :acronyms
    end
    
    self.pluralizations = [
      [/\z/, 's'],
      [/s\z/i, 's'],
      [/(ax|test)is\z/i, '\1es'],
      [/(.*)us\z/i, '\1uses'],
      [/(octop|vir|cact)us\z/i, '\1i'],
      [/(octop|vir)i\z/i, '\1i'],
      [/(alias|status)\z/i, '\1es'],
      [/(buffal|domin|ech|embarg|her|mosquit|potat|tomat)o\z/i, '\1oes'],
      [/(?<!b)um\z/i, '\1a'],
      [/([ti])a\z/i, '\1a'],
      [/sis\z/i, 'ses'],
      [/(.*)(?:([^f]))fe*\z/i, '\1\2ves'],
      [/(hive|proof)\z/i, '\1s'],
      [/([^aeiouy]|qu)y\z/i, '\1ies'],
      [/(x|ch|ss|sh)\z/i, '\1es'],
      [/(stoma|epo)ch\z/i, '\1chs'],
      [/(matr|vert|ind)(?:ix|ex)\z/i, '\1ices'],
      [/([m|l])ouse\z/i, '\1ice'],
      [/([m|l])ice\z/i, '\1ice'],
      [/^(ox)\z/i, '\1en'],
      [/^(oxen)\z/i, '\1'],
      [/(quiz)\z/i, '\1zes'],
      [/(.*)non\z/i, '\1na'],
      [/(.*)ma\z/i, '\1mata'],
      [/(.*)(eau|eaux)\z/, '\1eaux']]

    self.singularizations = [
      [/s\z/i, ''],
      [/(n)ews\z/i, '\1ews'],
      [/([ti])a\z/i, '\1um'],
      [/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)\z/i, '\1\2sis'],
      [/(^analy)(sis|ses)\z/i, '\1sis'],
      [/([^f])ves\z/i, '\1fe'],
      [/(hive)s\z/i, '\1'],
      [/(tive)s\z/i, '\1'],
      [/([lr])ves\z/i, '\1f'],
      [/([^aeiouy]|qu)ies\z/i, '\1y'],
      [/(s)eries\z/i, '\1eries'],
      [/(m)ovies\z/i, '\1ovie'],
      [/(ss)\z/i, '\1'],
      [/(x|ch|ss|sh)es\z/i, '\1'],
      [/([m|l])ice\z/i, '\1ouse'],
      [/(us)(es)?\z/i, '\1'],
      [/(o)es\z/i, '\1'],
      [/(shoe)s\z/i, '\1'],
      [/(cris|ax|test)(is|es)\z/i, '\1is'],
      [/(octop|vir)(us|i)\z/i, '\1us'],
      [/(alias|status)(es)?\z/i, '\1'],
      [/^(ox)en/i, '\1'],
      [/(vert|ind)ices\z/i, '\1ex'],
      [/(matr)ices\z/i, '\1ix'],
      [/(quiz)zes\z/i, '\1'],
      [/(database)s\z/i, '\1']]
    
    self.irregulars = [
      ['person', 'people'],
      ['man', 'men'],
      ['human', 'humans'],
      ['child', 'children'],
      ['sex', 'sexes'],
      ['foot', 'feet'],
      ['tooth', 'teeth'],
      ['goose', 'geese'],
      ['forum', 'forums']]

    self.uncountables = %w[hovercraft moose deer milk rain Swiss grass equipment information rice money species series fish sheep jeans]

    self.acronyms = {}
  end
end
