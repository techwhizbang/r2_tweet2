module Twitter

  module R2Tweet2
    def self.included(base)
      base.extend(ClassMethods)
      class << base
        attr_accessor :r2_tweet2_attributes
        attr_accessor :r2_tweet2_callbacks
        attr_accessor :r2_tweet2_inclusions
        attr_accessor :format
      end
    end

    module ClassMethods
      def r2_tweet2(*args)
        tweet_options = args[0]
        self.r2_tweet2_attributes = tweet_options[:attributes]
        unless tweet_options[:callbacks].blank?
          self.r2_tweet2_inclusions = tweet_options[:include]
          self.r2_tweet2_callbacks = tweet_options[:callbacks] 
          self.r2_tweet2_callbacks.each do |callback|
            unless self.r2_tweet2_inclusions.blank?
              self.r2_tweet2_inclusions.each {|include| self.send(callback.to_sym, include.to_sym) }
            else
              self.r2_tweet2_available_methods.each {|method| self.send(callback.to_sym, method.to_sym)}
            end
          end
        end
        self.format = tweet_options[:format] ||= :json
      end

      def r2_tweet2_available_methods
        [:tweet]
      end
    end

    def tweet
      Twitter::Status.new.update(status_update, :format => self.class.format) unless status_update.blank?
    end

    protected

    def status_update
      tweet_string = ""
      self.class.r2_tweet2_attributes.each do |attribute|
        tweet_string += (" " + self.send(attribute.to_sym)).to_s unless self.send(attribute.to_sym).blank?
      end
      tweet_string.strip
    end

  end

end

ActiveRecord::Base.send(:include, Twitter::R2Tweet2)
