require 'open-uri'
URL_ROOT = "https://raw.githubusercontent.com/TheGnarCo/.gnarrc/main/rails/7/files/"

def sync_file(relative_path)
  File.open(relative_path, "wb") do |file|
    file.write(URI.open(`#{URL_ROOT}#{relative_path}`).read)
  end
end

# Add the current directory to the path Thor uses
# to look up files
def source_paths
  Array(super) +
    [__dir__]
end

def create_gnarly_rails_app
  # This is a really unfortunate, but necessary, line of code that resets the
  # cached Gemfile location so the generated application's Gemfile is used
  # instead of the generators Gemfile.
  ENV["BUNDLE_GEMFILE"] = nil

  # Prevent spring cache when generating application
  ENV["DISABLE_SPRING"] = "true"

  add_gems

  run_bundle

  after_bundle do
    setup_testing
    setup_binstubs
    setup_database
    setup_assets
    setup_gitignore
    setup_linting
    setup_pronto
    setup_simplecov
    setup_environments
    setup_readme
    remove_dir "test"
    git :init
    format_ruby
    completion_notification
  end
end

def add_gems
  gem_group :development, :test do
    gem "axe-core-capybara"
    gem "axe-core-rspec"
    gem "bullet"
    gem "dotenv-rails"
    gem "factory_bot_rails"
    gem "gnar-style", require: false
    gem "launchy"
    gem "lol_dba"
    gem "okcomputer"
    gem "pronto"
    gem "pronto-rubocop", require: false
    gem "pry-byebug"
    gem "pry-rails"
    gem "rspec-its"
    gem "rspec-rails", "~> 4"
    gem "rubocop-rspec", require: false
    gem "shoulda-matchers"
    gem "simplecov", require: false
  end
end

def setup_database
  remove_file "config/database.yml"
  sync_file "config/database.yml"
  gsub_file "config/database.yml", "__application_name__", app_name
  gsub_file "Gemfile", /.*sqlite.*\n/, ""
end

def setup_assets
  run "yarn add esbuild-rails"
  remove_file "esbuild.config.js"
  sync_file 'esbuild.config.js'
  run "npm set-script build 'node esbuild.config.js'"
end

def setup_gitignore
  append_to_file ".gitignore" do
    <<~GITIGNORE
      # Ignore Byebug command history file.
      .byebug_history

      # Ignore output of simplecov
      coverage
    GITIGNORE
  end
end

def setup_testing
  setup_rspec
  setup_factory_bot
  setup_system_tests
  setup_shoulda
  setup_bullet
  limit_test_logging
end

def setup_rspec
  generate "rspec:install"
  remove_file ".rspec"
  sync_file ".rspec"
  gsub_file "spec/rails_helper.rb",
    /# Dir\[Rails\.root\.join.*/,
    "Dir[Rails.root.join(\"spec/support/**/*.rb\")].each { |f| require f }"
end

def setup_factory_bot
  sync_file "spec/support/factory_bot.rb"
end

def setup_system_tests
  sync_file "spec/support/system_test_configuration.rb"

  insert_into_file "spec/rails_helper.rb", after: "Rails is not loaded until this point!\n" do
    system_tests_rails_helper_text
  end

  append_to_file "spec/rails_helper.rb" do
    "\nCapybara.default_max_wait_time = 3\n"
  end
end

def system_tests_rails_helper_text
  <<~SYSTEM_TESTS
    require "capybara/rails"
    require "axe-rspec"
    require "axe-capybara"
    require "selenium/webdriver"
  SYSTEM_TESTS
end

def setup_shoulda
  append_to_file "spec/rails_helper.rb" do
    shoulda_rails_helper_text
  end
end

def shoulda_rails_helper_text
  <<~SHOULDA

    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  SHOULDA
end

def setup_bullet
  insert_into_file "config/environments/test.rb", after: "Rails.application.configure do" do
    bullet_test_env_text
  end

  insert_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|" do
    bullet_rails_helper_text
  end
end

def bullet_test_env_text
  <<-BULLET_TEST

  # Bullet gem initialization
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = true
  end
  BULLET_TEST
end

def bullet_rails_helper_text
  <<-BULLET_RAILS

  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
  BULLET_RAILS
end

def limit_test_logging
  insert_into_file "config/environments/test.rb", after: "Rails.application.configure do" do
    <<-TEST_LOGGING

  unless ENV[\"RAILS_ENABLE_TEST_LOG\"]
    config.logger = Logger.new(nil)
    config.log_level = :fatal
  end
    TEST_LOGGING
  end
end

def setup_binstubs
  remove_file "bin/setup"
  sync_file "bin/setup"
  run "chmod +x bin/setup"

  sync_file "bin/rspec"
  run "chmod +x bin/rspec"

  sync_file "bin/rubocop"
  run "chmod +x bin/rubocop"
end

def setup_linting
  sync_file ".rubocop.yml"
end

def setup_pronto
  sync_file ".pronto.yml"

  sync_file "templates/bin/pronto", "bin/pronto"
  run "chmod +x bin/pronto"

  sync_file ".github/workflows/pronto.yml"
end

def setup_simplecov
  prepend_to_file "spec/spec_helper.rb" do
    <<~SIMPLECOV
      require "simplecov"

      # Save to CircleCI's artifacts directory if we're on CircleCI
      if ENV["CIRCLE_ARTIFACTS"]
        dir = File.join(ENV["CIRCLE_ARTIFACTS"], "coverage")
        SimpleCov.coverage_dir(dir)
      end

      SimpleCov.start "rails" if (ENV["CI"] || ENV["COVERAGE"])

    SIMPLECOV
  end
end

def setup_environments
  setup_dotenv
  setup_github_workflows
  setup_docker
  setup_procfile
  configure_i18n
end

def setup_dotenv
  sync_file ".env.development"
  sync_file ".env.test"
  gsub_file ".env.development", "__application_name__", app_name
  gsub_file ".env.test", "__application_name__", app_name
end

def setup_github_workflows
  sync_file ".github/workflows/run-tests.yml"
  sync_file ".github/workflows/brakeman.yml"

  sync_file ".github/actions/test-rails/action.yml"
  sync_file ".github/workflows/bundler-audit.yml"
end

def setup_docker
  sync_file "Dockerfile"
  gsub_file "Dockerfile", "__ruby_version__", RUBY_VERSION

  setup_docker_standard
end

def setup_procfile
  sync_file "Procfile"
end

def setup_docker_standard
  sync_file ".env.docker"
  sync_file "docker-compose.yml"
end

def setup_readme
  remove_file "README.md"
  sync_file "README.md"
  gsub_file "README.md", "__application_name__", app_name
end

def configure_i18n
  gsub_file(
    "config/environments/test.rb",
    "# config.action_view.raise_on_missing_translations = true",
    "config.action_view.raise_on_missing_translations = true",
  )
  gsub_file(
    "config/environments/development.rb",
    "# config.action_view.raise_on_missing_translations = true",
    "config.action_view.raise_on_missing_translations = true",
  )
end

def ascii_art
  puts "  _____     __        _     ____     ____     "
  puts " / / \\ \\   |  \\      | |   /    \\   |    \\    "
  puts "| |  | |   |   \\     | |  |  /\\  |  | |\\  \\   "
  puts "| |   -    |    \\    | |  | |  | |  | | |  |  "
  puts "| |        |  |\\ \\   | |  | |__| |  | |/  /   "
  puts "| |  / --  |  | \\ \\  | |  | |  | |  |    /    "
  puts "| |    \\ \\ |  |  \\ \\ | |  | |  | |  | |\\ \\    "
  puts " \\ \\   | | |  |   \\ \\| |  | |  | |  | | \\ \\   "
  puts "  \\  --/ / |  |    \\   |  | |  | |  | |  \\ \\  "
  puts "   -----/  |__|     \\__|  |_|  |_|  |_|   \\_\\ "
end

def post_install_instructions
  puts "\n\nNEXT STEPS"
  puts "=========="
  puts "* Install Google Chrome for acceptance tests"
  puts "* Ensure you have Homebrew Cask installed: brew tap homebrew/cask"
  puts "* Install ChromeDriver for default headless acceptance tests: brew cask install chromedriver"
  puts "* Follow the post-install instructions to set up circle to allow gnarbot to comment on PRs."
  puts "  * https://github.com/TheGnarCo/gnarails#post-install"
  puts "=========="
  puts "* Make sure your package.json has the following scripts:"
  puts "* \`\"build\": \"node esbuild.config.js\"\`"
  puts "* \`\"build:css\": \"sass ./app/assets/stylesheets/application.sass.scss ./app/assets/builds/application.css --no-source-map --load-path=node_modules\"\`"
end

def format_ruby
  run "bin/rubocop -A"
end

def completion_notification
  puts ""
  ascii_art
  post_install_instructions
end

create_gnarly_rails_app
