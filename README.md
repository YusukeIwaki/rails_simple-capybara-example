# Use Capybara only for launch server.

```rb
  it 'can browse' do
    page.goto("#{base_url}/test")
    page.wait_for_selector('input', visible: true)
    page.type_text('input', 'hoge')
    page.keyboard.press('Enter')
    expect(page.eval_on_selector('#content', 'el => el.textContent')).to include('hoge')
  end
```

![demo](demo.gif)
