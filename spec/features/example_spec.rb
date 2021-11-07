require 'rails_helper'

describe 'example', driver: :null do
  let!(:user) { FactoryBot.create(:user) }
  let(:page) { @playwright_page }

10.times do
  it 'can browse' do
    page.goto("/tests/#{user.id}")
    page.wait_for_selector('input').type('hoge')
    page.keyboard.press('Enter')
    expect(page.text_content('#content')).to include('hoge')
  end
end
end
