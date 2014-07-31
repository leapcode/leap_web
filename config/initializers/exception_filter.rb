class ActionDispatch::DebugExceptions
  def log_error_with_exception_filter(env, wrapper)
    if wrapper.exception.is_a?  ActionController::RoutingError
      return
    else
      log_error_without_exception_filter env, wrapper
    end
  end
  alias_method_chain :log_error, :exception_filter
end
