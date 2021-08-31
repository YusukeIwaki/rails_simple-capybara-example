require 'rails_helper'

describe 'example' do
  let(:base_url) { @server_base_url }
  let(:page) { @puppeteer_page }

  let(:user) { FactoryBot.create(:user) }

100.times do
  it 'can browse' do
    page.goto("#{base_url}/tests/#{user.id}")
    page.wait_for_selector('input', visible: true)
    page.type_text('input', 'hoge')
    page.keyboard.press('Enter')

    text = page.eval_on_selector('#content', 'el => el.textContent')
    expect(text).to include('hoge')
    expect(text).to include(user.name)
  end
end
end
