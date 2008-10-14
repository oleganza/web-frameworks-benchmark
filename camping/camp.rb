require 'rubygems'
require 'camping'

Camping.goes :Camp

module Camp::Models
end

module Camp::Controllers
  class Index < R '/'
    def get
      render :index
    end
  end
end

module Camp::Views
  def layout
    yield
  end

  def index
    "Hello from Camping!"
  end
end
