RSpec.configure do |config|
  require 'playwright'

  config.before(:suite) do
    # Railsアプリケーションの起動
    require 'rack/builder'
    testapp = Rack::Builder.app(Rails.application) do
      map '/__ping' do
        run ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
      end
    end

    require 'rack/handler/puma'
    server_thread = Thread.new do
      Rack::Handler::Puma.run(testapp,
        Port: 3000,
        Threads: '0:4',
        workers: 0,
        daemon: false,
      )
    end

    require 'net/http'
    require 'timeout'
    Timeout.timeout(3) do
      loop do
        puts "try"
        puts Net::HTTP.get(URI("http://127.0.0.1:3000/__ping"))
        break
      rescue Errno::EADDRNOTAVAIL
        sleep 1
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end
    end
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
