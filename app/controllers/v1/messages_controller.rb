module V1
  class MessagesController < ApiController

    before_filter :require_login

    def index
      if Dir.exist?(motd_dir)
        if !CommonLanguages::available_code?(params[:locale])
          locale = 'en'
        else
          locale = params[:locale]
        end
        render json: motd_files_for_locale(locale)
      else
        render json: []
      end
    end

    # disable per-user messages for now, not supported in the client
    #def update
    #  if message = Message.find(params[:id])
    #    message.mark_as_read_by(current_user)
    #    message.save
    #    render json: success(:marked_as_read)
    #  else
    #    render json: error(:not_found), status: :not_found
    #  end
    #end

    private

    #
    # returns list of messages, for example:
    #
    # [
    #   {"id": 1, "locale": "en", "text": "<message text>"},
    #   {"id": 2, "locale": "en", "text": "<message text>"}
    # ]
    #
    # Each message is present only once, using the best choice
    # for the locale. The order is determined by the id.
    #
    def motd_files_for_locale(locale)
      files = []
      motd_files.keys.each do |id|
        if motd_files[id].key?(locale)
          msg_locale = locale
        elsif motd_files[id].key?('en')
          msg_locale = 'en'
        else
          msg_locale = motd_files[id].keys.first
        end
        files << {
          "id" => id,
          "locale" => msg_locale,
          "text" => motd_files[id][msg_locale]
        }
      end
      files.sort! {|a,b| a["id"].to_i <=> b["id"].to_i }
      return files
    end

    #
    # returns messages of the day as a hash:
    # { "1": {"en": "message"}, "2": {"en": "message"} }
    #
    def motd_files
      if motd_changed? || @motd_files.nil?
        @motd_files = load_motd_files
      else
        @motd_files
      end
    end

    def motd_changed?
      newest = Dir.glob(File.join(motd_dir, '*.{html,md}')).collect{|file| File.mtime(file)}.max
      if @timestamp.nil?
        @timestamp = newest
        return true
      elsif @timestamp < newest
        @timestamp = newest
        return true
      else
        return false
      end
    end

    def load_motd_files
      files = {}
      Dir.glob(File.join(motd_dir, '*.{html,md}')).each do |file|
        id, locale, msg = parse_motd_file(file)
        next unless id
        files[id] ||= {}
        files[id][locale] = msg
      end
      files
    end

    def parse_motd_file(file)
      id, locale, ext = File.basename(file).split('.')
      if id.nil? || locale.nil? || ext.nil? || id.to_i.to_s != id || !['md', 'html'].include?(ext)
        Rails.logger.error "ERROR: Could not parse MOTD file #{file}"
        return nil
      end
      contents = File.read(file)
      if ext == "md"
        msg = RDiscount.new(contents, :autolink).to_html
      elsif ext == "html"
        msg = File.read(file)
      end
      return id, locale, msg
    end

    def motd_dir
      File.join(APP_CONFIG['customization_directory'], 'motd')
    end

  end
end
