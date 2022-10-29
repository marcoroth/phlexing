# Phlexing

[![Tests](https://github.com/marcoroth/phlexing/actions/workflows/tests.yml/badge.svg)](https://github.com/marcoroth/phlexing/actions/workflows/tests.yml)
[![Rubocop](https://github.com/marcoroth/phlexing/actions/workflows/rubocop.yml/badge.svg)](https://github.com/marcoroth/phlexing/actions/workflows/rubocop.yml)

A simple ERB to [Phlex](https://github.com/marcoroth/phlexing) Converter.

<a href="https://phlexing.fun">
  <img src="./screenshot.png" alt="Phlexing Screenshot">
</a>

## Website

A hosted version of the converter is running at [https://phlexing.fun](https://phlexing.fun).


## Using the gem

### Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add phlexing

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install phlexing

### Usage

```ruby
require "phlexing"

Phlexing::Converter.convert('<h1 class="title">Hello World</h1>')
=> "h1(class: \"title\") { \"Hello World\" }\n"

Phlexing::Converter.convert(%{
  <% @articles.each do |article| %>
    <h1><%= article.title %></h1>
  <% end %>
})
=> "@articles.each do |article|
     h1 { article.title }

     whitespace
   end"

```

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcoroth/phlexing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/marcoroth/phlexing/blob/master/CODE_OF_CONDUCT.md).

### License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### Code of Conduct

Everyone interacting in the Phlexing project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/marcoroth/phlexing/blob/master/CODE_OF_CONDUCT.md).
