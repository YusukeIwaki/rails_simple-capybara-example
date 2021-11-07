RSpec.configure do |config|
  require 'playwright'

  config.before(:suite) do
    # Railsアプリケーションの起動
    require 'rack/test_server'
    server = Rack::TestServer.new(app: Rails.application, server: :webrick, Port: 3000)

    server.start_async
    server.wait_for_ready
    puts "done"
  end

  config.around(type: :feature) do |example|
    # Rails server is launched here, at the first time of accessing Capybara.current_session.server
    base_url = 'http://127.0.0.1:3000'

    Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
      # pass any option for Playwright#launch and Browser#new_page as you prefer.
      playwright.chromium.launch(headless: false) do |browser|
        @playwright_page = browser.new_page(baseURL: base_url)
        example.run
      end
    end
  end
end
