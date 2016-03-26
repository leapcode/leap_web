module LinkHelper

  Action = Struct.new(:target, :verb, :options) do
    def to_partial_path; 'common/action'; end
    def label; options[:label]; end
    def class; verb; end
    def url
      case verb
      when :show, :destroy then target
      when :edit, :new then [verb, target]
      end
    end

    def html_options
      if verb == :destroy
        {method: :delete}
      end
    end
  end

  def actions(target)
    target.actions.map do |action|
      Action.new target, action,
        label: t(".#{action}", cascade: true)
    end
  end

  #
  # markup for bootstrap button
  #
  # takes same arguments as link_to and adds a 'btn' class.
  # In addition:
  # * the name will be translated if it is a symbol
  # * html_options[:type] will be converted into a btn-type class
  #
  # example:
  # btn :home, home_path, type: [:large, :primary]
  #
  def btn(*args, &block)
    html_options = extract_html_options!(args, &block)
    type = Array(html_options.delete(:type))
    btn_opts = [:default, :primary, :success, :info, :warning, :danger, :link]
    if (type & btn_opts).blank?
      type << :default
    end
    type.map! {|t| "btn-#{t}"}
    html_options[:class] = concat_classes(html_options[:class], 'btn', type)
    args[0] = t(args[0]) if args[0].is_a?(Symbol)
    link_to *args, html_options, &block
  end

  def destroy_btn(*args, &block)
    html_options = extract_html_options!(args, &block)
    confirmation = t "#{controller_symbol}.confirm.destroy.are_you_sure",
      cascade: true
    html_options.merge! method: :delete, confirm: confirmation
    btn *args, html_options, &block
  end

  #
  # concat_classes will combine classes in a fairly flexible way.
  # it can handle nil, arrays, space separated strings
  # it returns a space separated string of classes.
  def concat_classes(*classes)
    classes.compact!
    classes.map {|c| c.respond_to?(:split) ? c.split(' ') : c }
    classes.flatten!
    classes.join ' '
  end

  def extract_html_options!(args)
    if args.count > 2 or args.count > 1 && block_given?
      args.extract_options!
    else
      {}
    end
  end
end
