# Partial Path Hints

Include in your Gemfile: 

```

group :development do
    gem 'actionview-path_hints'
end

```
**Do not use this in production.**

All partials will be wrapped in a border, red for uncached, green for cached. 

![cache test][cache_test]

Built for Rails 5 but added support for Rails 4. 

Feel free to [submit issues](https://github.com/ryaan-anthony/actionview-path_hints/issues) or [help make it better](https://github.com/ryaan-anthony/actionview-path_hints/pulls).




[cache_test]: https://raw.githubusercontent.com/ryaan-anthony/actionview-path_hints/master/docs/cache-test.png