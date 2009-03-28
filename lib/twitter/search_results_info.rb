module Twitter
  class SearchResultsInfo

    def initialize(hash)
      (class << self; self; end).class_eval do
        hash.each_pair do |key, value|
          if key == "results"
            define_method key.to_sym do
              results = []
              value.each do |result|
                results << SearchResult.new(result)
              end
              results
            end
          else
            define_method key.to_sym do
              value
            end
          end
        end
      end
    end
    
  end
end