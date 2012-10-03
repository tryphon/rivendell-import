module Rivendell::Import
  class Cart

    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON

    def attributes
      %w{number group}.inject({}) do |map, attribute|
        value = send attribute
        map[attribute] = value if value
        map
      end
    end

    def attributes=(attributes)
      attributes.each { |k,v| send "#{k}=", v }
    end

    delegate :blank?, :to => :attributes

    attr_accessor :number, :group
    attr_reader :task

    def initialize(task = nil)
      @task = task
    end

    def xport
      task.xport
    end

    def create
      unless number
        raise "Can't create Cart, Group isn't defined" unless group.present?
        self.number = xport.add_cart(:group => group).number
      end
    end

    def update
      # xport.edit_cart # to define title, etc ...
    end
    
    def cut
      @cut ||= Cut.new(self)
    end

    def import(file)
      raise "File #{file.path} not found" unless file.exists?

      cut.create
      xport.import number, cut.number, file.path
      cut.update
    end

    def find_by_title(string, options = {})
      if remote_cart = carts_cache.find_by_title(string, options)
        self.number = remote_cart.number
      end
    end

    def carts_cache
      @carts_cache ||= Rivendell::Import::CartsCache.new(xport)
    end

  end
end
  
