# RS.GE ვებ-სერვისები

ეს ბიბლიოთეკა განკუთვნილია RS.GE-ს ვებ სერვისების გამოყენებაზე.
ამ ბიბლიოთეკის მეშვეობით ადვილად მოახერხებთ ყველა ოპერაციის ჩატარებას,
რასაც აღნიშნული ვებ სერვისი ითვალისწინებს.

## გამოყენება

გამოყენებისათვის უნდა ჩასვათ შემდეგი ხაზი თქვენს Gemfile-ში:

	gem 'rs'

შემდეგი გამოყენება ძალიან მარტივია:

```ruby
require 'rs'

puts RS.what_is_my_ip # თქვენს IP მისამართს დაბეჭდავს კონსოლში
```

## სხვა ფუნქციები

TODO: აქ დასაწერია თუ როგორ უნდა გამოიყენოთ სხვა ფუნქციები (დასალაგებბელია თემეტურად)