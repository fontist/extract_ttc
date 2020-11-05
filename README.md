# ExtractTtc

The gem lets extract TTC font collection files.

It wraps stripttc.c from the FontForge project as FFI extension.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'extract_ttc'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install extract_ttc

## Usage

```ruby
ExtractTtc.extract("path/to/ttc/Helvetica.ttc")
```

Would extract contained TTF files from TTC to a current directory.

## Development

We are following Sandi Metz's Rules for this gem, you can read the
[description of the rules here][sandi-metz] All new code should follow these
rules. If you make changes in a pre-existing file that violates these rules you
should fix the violations as part of your contribution.

### Setup

Clone the repository

```sh
git clone https://github.com/fontist/extract_ttc
```

Setup your environment

```sh
bin/setup
```

Run the test suite

```sh
bundle exec rspec
```

If any changes are made in the C code, then the extension needs to be recompiled

```sh
bundle exec rake recompile
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](rubygems).


## Contributing

First, thank you for contributing! We love pull requests from everyone. By
participating in this project, you hereby grant [Ribose Inc.][riboseinc] the
right to grant or transfer an unlimited number of non exclusive licenses or
sub-licenses to third parties, under the copyright covering the contribution
to use the contribution by all means.

Here are a few technical guidelines to follow:

1. Open an [issue][issues] to discuss a new feature.
1. Write tests to support your new feature.
1. Make sure the entire test suite passes locally and on CI.
1. Open a Pull Request.
1. [Squash your commits][squash] after receiving feedback.
1. Party!


## Credit

This gem is developed, maintained and funded by [Ribose Inc.][riboseinc]


[rubygems]: https://rubygems.org
[riboseinc]: https://www.ribose.com
[issues]: https://github.com/fontist/extract_ttc/issues
[squash]: https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature
[sandi-metz]: http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers
