module Twitter
  class SearchResultsInfo

    def initialize(hash)
      (class << self; self; end).class_eval do
        hash.each_pair do |key, value| 
          define_method key.to_sym do
            if key.to_s == "results"
              results = []
              value.each { |r| results << SearchResult.new(r) }
              results
            else
              value.to_s
            end
          end
        end
      end
    end
    
  end
end
