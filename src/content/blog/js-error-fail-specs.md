---
title: 'JS Errors Failing RSpec'
description: 'One of the most frustrating classes of bugs in web applications is the JavaScript error that never causes a test to fail.'
pubDate: 2026-09-16
draft: true
heroImage: '../../assets/blog-placeholder-1.jpg'
---
# Making JS Console Errors Fail RSpec System Tests

One of the most frustrating classes of bugs in web applications is the JavaScript error that never causes a test to fail.

A feature spec passes.
The page appears to work.
CI is green.

Meanwhile, the browser console is full of errors that users encounter every day.

I ran into this problem while working on Rails applications with Capybara and Selenium. We wanted our system tests to catch JavaScript problems automatically instead of relying on developers to notice them manually in browser devtools.

## The Problem

Consider a page that loads successfully but throws a JavaScript exception:

```javascript
Uncaught TypeError: Cannot read properties of undefined
```

The page may still render.

The user may even be able to complete the workflow.

From the test's perspective:

```ruby
visit('/articles')

expect(page).to have_content('Articles')
```

Everything passes.

The console error goes unnoticed.

## Capturing Browser Logs

Selenium can expose browser console logs from Chrome.

When configuring the driver, enable browser logging:

```ruby
options = Selenium::WebDriver::Chrome::Options.new

options.add_option('goog:loggingPrefs', browser: 'ALL')
```

After each system test, retrieve the browser logs:

```ruby
logs = page.driver.browser.logs.get(:browser)
```

## Failing on Severe Errors

We only wanted to fail tests for severe JavaScript errors.

Example:

```ruby
RSpec.configure do |config|
  config.after(:each, type: :system) do
    logs = page.driver.browser.logs.get(:browser)

    js_errors = logs.select { |log| log.level == 'SEVERE' }

    expect(js_errors).to(be_empty, js_errors.map(&:message).join("\n"))
  end
end
```

Now a console error causes the test to fail immediately.

## Handling Expected Errors

Not every console error is worth failing a test.

For example, some applications intentionally return:

```text
422 Unprocessable Entity
```

during validation workflows.

We added filtering for known and expected messages:

```ruby
js_errors = logs.reject do |log|
  log.message.include?('422 (Unprocessable Content)')
end
```

The exact filtering logic depends on your application.

The goal is to catch unexpected errors without generating noise.

## Opting Out When Necessary

Occasionally a test needs to ignore JavaScript errors.

We introduced metadata:

```ruby
it 'tests a known error condition', :allow_js_errors do
  ...
end
```

Then skipped the check:

```ruby
next if example.metadata[:allow_js_errors]
```

This kept the default behavior strict while still allowing exceptions when necessary.

## Results

The biggest benefit wasn't finding catastrophic failures.

It was finding small regressions that otherwise would have reached production unnoticed:

- Missing JavaScript imports
- Undefined variables
- Broken event handlers
- Failed API requests
- Client-side rendering issues

Many of these problems still allowed the page to render, which meant traditional system tests never noticed them.

By treating unexpected browser console errors as test failures, we gained another layer of protection with very little additional test code.

## Final Thoughts

System tests already exercise a real browser.

The browser is telling us when something goes wrong.

Surfacing those errors in CI is one of the simplest ways to increase confidence in your test suite and catch issues before users do.
