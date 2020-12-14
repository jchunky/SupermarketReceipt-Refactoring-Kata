require "active_support/all"
relative_load_paths = %w[lib]
ActiveSupport::Dependencies.autoload_paths += relative_load_paths
