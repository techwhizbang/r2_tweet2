module Twitter
  class Search < Base
    include Enumerable
    SEARCH = "http://search.twitter.com/search"

    attr_reader :result, :query

    def initialize(q=nil)
      clear
      containing(q) if q && q.strip != ''
    end

    def from(user, operator = nil)
      if operator.nil?
        @query[:q] << "from:#{user}"
      else
        @query[:or] << (@query[:or].size == 0 ? "from:#{user}" : "#{operator} from:#{user}")
      end

      self
    end

    def to(user, operator = nil)
      if operator.nil?
        @query[:q] << "to:#{user}"
      else
        @query[:or] << (@query[:or].size == 0 ? "to:#{user}" : "#{operator} to:#{user}")
      end
  
      self
    end
  
    def referencing(user, operator = nil)
      if operator.nil?
        @query[:q] << "@#{user}"
      else
        @query[:or] << (@query[:or].size == 0 ? "@#{user}" : "#{operator} @#{user}")
      end

      self
    end
    alias :references :referencing
    alias :ref :referencing

    def containing(word, operator = nil)
      if operator.nil?
        @query[:q] << "#{word}"
      else
        @query[:or] << (@query[:or].size == 0 ? "#{word}" : "#{operator} #{word}")
      end

      self
    end
    alias :contains :containing

    # adds filtering based on hash tag ie: #twitter
    def hashed(tag, operator = nil)
      if operator.nil?
        @query[:q] << "##{tag}"
      else
        @query[:or] << (@query[:or].size == 0 ? "##{tag}" : "#{operator} ##{tag}")
      end
 
      self
    end
    alias :hash :hashed

    # lang must be ISO 639-1 code ie: en, fr, de, ja, etc.
    #
    # when I tried en it limited my results a lot and took
    # out several tweets that were english so i'd avoid
    # this unless you really want it
    def lang(lang)
      @query[:lang] = lang
      self
    end

    # Limits the number of results per page
    def per_page(num)
      @query[:rpp] = num
      self
    end

    # Which page of results to fetch
    def page(num)
      @query[:page] = num
      self
    end

    # Only searches tweets since a given id.
    # Recommended to use this when possible.
    def since(since_id)
      @query[:since_id] = since_id
      self
    end

    # Search tweets by longitude, latitude and a given range.
    # Ranges like 25km and 50mi work.
    def geocode(long, lat, range)
      @query[:geocode] = [long, lat, range].join(',')
      self
    end

    # Clears all the query filters to make a new search
    def clear
      @query = {}
      @query[:q], @query[:or] = [], []
      self
    end

    # If you want to get results do something other than iterate over them.
    def fetch(format = :json)
      combine_queries
      connection = Connection.new SEARCH, format
      response = connection.http_connect { connection.create_http_get_request(@query) }
      response_conversion(response.body, format)
    end

    def each
      @results = fetch
      @results.results.each { |r| yield r }
    end

    def response_conversion(body, format = :json)
      response = super body, format
      SearchResultsInfo.new(response) if format == :json
    end

    protected

    def combine_queries
      if @query[:q].is_a?(Array) and @query[:or].is_a?(Array)
        if !@query[:or].blank?
          @query[:q] = @query[:q].blank? ? @query[:or].join(' ') : @query[:q].join(' ') + " OR " + @query[:or].join(' ')    
        else
          @query[:q] = @query[:q].join(' ')
        end
      end
      @query[:q]
    end
  end
end