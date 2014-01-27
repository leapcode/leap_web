module LeapWebCore
  class Dependencies
    UI_DEV = {
      "haml-rails" => "~> 0.3.4",
      "sass-rails" => "~> 3.2.5",
      "coffee-rails" => "~> 3.2.2",
      "uglifier" => "~> 1.2.7"
    }

    UI = {
      "haml" =>  "~> 3.1.7",
      "jquery-rails" => nil,
      "simple_form" => nil,
      "bootswatch-rails", "~> 0.5.0"
    }

    def self.require_ui_gems
      UI.keys.each {|dep| require dep}
      if Rails.env == "development"
        # This will be run in the app including plugins that run it.
        # However not all development_dependencies might be present.
        # So we better only require those that are.
        available = Bundler.definition.specs.map(&:name)
        gems_to_require = available & UI_DEV.keys
        gems_to_require.each {|dep| require dep}
      end
    end

    def self.add_ui_gems_to_spec(spec)
      UI.each do |dep, version|
        spec.add_dependency dep, version
      end

      UI_DEV.each do |dep, version|
        spec.add_development_dependency dep, version
      end
    end

  end
end
