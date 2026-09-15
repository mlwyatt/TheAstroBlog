---
title: Detecting Flaky RSpec Specs
description: Techniques for finding flaky tests in Rails applications.
pubDate: 2026-09-14
draft: true
heroImage: '../../assets/blog-placeholder-2.jpg'
tags:
  - Rails
  - RSpec
  - Testing
---

Flaky tests are one of the biggest sources of CI frustration.

In our applications, we've found most flaky specs fall into a few categories:

## Order Dependencies

RSpec runs with random ordering:

```ruby
config.order = :random
