# encoding: utf-8

module CommonLanguages
  class Language
    attr_accessor :code, :name, :english_name, :rtl
    def initialize(data)
      @code = data[0].to_sym
      @name = data[1]
      @english_name = data[2] || data[1]
      @rtl = data[3] === true
    end
    def rtl?
      @rtl
    end
    def ==(l)
      @code == l.code && @name = l.name
    end
  end
end
