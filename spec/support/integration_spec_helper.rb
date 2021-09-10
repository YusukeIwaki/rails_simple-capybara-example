class RackTestServer
  def initialize(app:, **options)
    @options = options

    @options[:Host] ||= 'localhost'
    @options[:Port] ||= 3000

    require 'rack/builder'
    @options[:app] = Rack::Builder.app(app) do
      map '/__ping' do
        run ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
      end
    end
  end

  def base_url
    "http://#{@options[:Host]}:#{@options[:Port]}"
  end

  def start
    require 'rack/server'
    Rack::Server.start(**@options)
  end

  def ready?
    require 'net/http'
    begin
      Net::HTTP.get(URI("#{base_url}/__ping"))
      true
    rescue Errno::EADDRNOTAVAIL
      false
    rescue Errno::ECONNREFUSED
      false
    end
  end

  def wait_for_ready(timeout: 3)
    require 'timeout'
    Timeout.timeout(3) do
      sleep 0.1 until ready?
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    # Launch Rails application
    test_server = RackTestServer.new(
      # options for Rack::Server
      # https://github.com/rack/rack/blob/2.2.3/lib/rack/server.rb#L173
      app: Rails.application,
      server: :puma,
      Host: '127.0.0.1',
      Port: 3000,
      daemonize: false,

      # options for Rack::Handler::Puma
      # https://github.com/puma/puma/blob/v5.4.0/lib/rack/handler/puma.rb#L84
      Threads: '0:4',
      workers: 0,
    )

    Thread.new { test_server.start }
    test_server.wait_for_ready
  end

  config.around(type: :feature) do |example|
    Puppeteer.launch(channel: :chrome, headless: false) do |browser|
      @server_base_url = 'http://127.0.0.1:3000'
      @puppeteer_page = browser.new_page
      example.run
    end
  end
end
