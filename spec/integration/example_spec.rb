require 'rails_helper'

describe 'example' do
  # A driver just for launching HTTP Server.
  class NullDriver < Capybara::Driver::Base
    def needs_server?
      true
    end
  end

  before(:all) do
    Capybara.server = :puma, { Silent: false }
    Capybara.register_driver(:null) { NullDriver.new }
  end

  around do |example|
    Capybara.current_driver = :null
    @server_base_url = Capybara.current_session.server.base_url

    Puppeteer.launch(channel: 'chrome', headless: false) do |browser|
      @puppeteer_page = browser.new_page
      example.run
    end

    Capybara.use_default_driver
  end
  let(:base_url) { @server_base_url }
  let(:page) { @puppeteer_page }

  it 'can browse' do
    page.goto("#{base_url}/test")
    page.wait_for_selector('input', visible: true)
    page.type_text('input', 'hoge')
    page.keyboard.press('Enter')
    expect(page.eval_on_selector('#content', 'el => el.textContent')).to include('hoge')
  end
end
