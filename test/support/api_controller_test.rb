class ApiControllerTest < ActionController::TestCase

  def api_get(*args)
    get *add_api_defaults(args)
  end

  def api_post(*args)
    post *add_api_defaults(args)
  end

  def api_delete(*args)
    delete *add_api_defaults(args)
  end

  def api_put(*args)
    put *add_api_defaults(args)
  end

  def add_api_defaults(args)
    add_defaults args, version: '2'
  end

  def add_defaults(args, defaults)
    opts = args.extract_options!
    opts.reverse_merge! defaults
    args << opts
    args
  end
end
