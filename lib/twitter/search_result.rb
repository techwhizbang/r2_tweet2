module Twitter
  class SearchResult

    def initialize(hash)
      (class << self; self; end).class_eval do
        hash.each_pair do |key, value|
          define_method key.to_sym do
            value
          end
        end
      end
    end
    
  end
end
