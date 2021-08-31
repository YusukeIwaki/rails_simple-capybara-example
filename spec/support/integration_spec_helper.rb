RSpec.configure do |config|
  config.before(:suite) do
    # Launch Rails application
    require 'rack/builder'
    testapp = Rack::Builder.app(Rails.application) do
      map '/__ping' do
        run ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
      end
    end

    require 'rack/handler/puma'
    server_thread = Thread.new do
      Rack::Handler::Puma.run(testapp,
        Host: '127.0.0.1',
        Port: 3000,
        Threads: '0:4',
        workers: 0,
        daemonize: false,
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
    Puppeteer.launch(channel: :chrome, headless: false) do |browser|
      @server_base_url = 'http://127.0.0.1:3000'
      @puppeteer_page = browser.new_page
      example.run
    end
  end
end
