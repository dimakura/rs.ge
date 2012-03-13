# RS.GE ვებ-სერვისები

ეს ბიბლიოთეკა განკუთვნილია RS.GE-ს ვებ სერვისების გამოყენებაზე.
ამ ბიბლიოთეკის მეშვეობით ადვილად მოახერხებთ ყველა ოპერაციის ჩატარებას,
რასაც აღნიშნული ვებ სერვისი ითვალისწინებს.

## გამოყენება

გამოყენებისათვის უნდა ჩასვათ შემდეგი ხაზი თქვენს Gemfile-ში:

```
gem 'rs.ge', '~> 0.0.7'
```

შემდეგი გამოყენება ძალიან მარტივია:

```ruby
require 'rs'

puts RS.what_is_my_ip # თქვენს IP მისამართს დაბეჭდავს კონსოლში
```

## სისტემური ფუნქციები

თქვენი IP-ს გასაგებად შეგიძლიათ გამოიყენოთ `what_is_my_ip` ფუნქცია:

```ruby
my_ip = RS.what_is_my_ip
```

სერვისის სხვა მეთოდების გამოსაყენებლად უნდა გქონდეთ შექმნილი სერვისის მომხმარებელი.
სერვისის მომხმარებლის შესაქმენლად დაგჭირდებათ თქვენს ორგანიზაციაზე მინიჭებული მომხმარებლის სახელი და პაროლი.

ახალი სერვისის მომხმარებლის შესაქმნელად გამოიყენეთ `create_service_user` ფუნქცია:

```ruby
was_created = RS.create_service_user(params)
```

`params` წარმოადგენს შემდეგი მონაცემების ჰეშს (ყველა პარამეტრი აუცილებელია):

- `user_name` &mdash; თქვენი ორგანიზაციის მომხმარებლის სახელი;
- `user_password` &mdash; თქვენი ორგანიზაციის პაროლი;
- `ip` &mdash; IP მისამართი, რომლიდანაც შეგიძლიათ იმუშაოთ;
- `su` &mdash; ახალი სერვისის მომხმარებლის სახელი;
- `sp` &mdash; სერვისის მომხმარებლის პაროლი.

ეს ფუნქცია აბრუნებს `boolean` ტიპის მნიშვნელობას: თუ მომხმარებელი შეიქმნა, ბრუნდება `true`, ხოლო `false` &mdash; წინააღმდეგ შემთხვევაში. თუ რატომ არ მოხდა მომხმარებლის გახსნა შეიძლება მხოლოდ ვივარაუდოდ: ამის შესახებ rs-ის სერვისი არანაირ პასუხს არ იძლევა.

ძალაინ მნიშვნელოვანი ფუნქციაა `check_service_user`, რომელიც გარდა იმისა, რომ ამოწმებს ახლად შექმნილი მომხმარებლის სახელს და პაროლს, ასევე გაძლევთ შანსს გაიგოთ თქვენი ორგანიზაციის გადამხდელის ID. ამ ფუნქციის გამოძახება ასე გამოიყურება:

```ruby
user = RS.check_service_user(params)
```

გადასაცემი პარამეტრების სია გაცილებით მოკრძალებულია:

- `su` &mdash; სერვისის მომხმარებლის სახელი;
- `sp` &mdash; სერვისის მომხმარებლის პაროლი.

თუ `su` და `sp` პარამეტრების სწორადაა მოწოდებულია, მაშინ `RS::User` ობიექტი ბრუნდება, რომელიც შეიცავს `payer_id` თვისებას, სადაც თქვენი ორგანიზაციის გადამხდელის საიდენტიფიკაციო კოდია ჩაწერილი. თუ ავტორიზაციის მონაცემები არასწორადაა მიწოდებული, ეს მეთოდი დააბრუნებს `nil` მნიშვნელობას.

ასევე მარტივია მომხმარებლის მონაცემების შეცვლა. ამისათვის `update_service_user` მეთოდი შეგიძლიათ გამოიყენოთ:


```ruby
was_updated = RS.create_service_user(params)
```

`params` წარმოადგენს მონაცემების ჰეშს, რომელიც მსგავსია იმისა, რასაც გადავცემდით `create_service_user` ფუნქციის გამოძახებისა:

- `user_name` &mdash; თქვენი ორგანიზაციის მომხმარებლის სახელი;
- `user_password` &mdash; თქვენი ორგანიზაციის პაროლი;
- `ip` &mdash; IP მისამართი, რომლიდანაც შეგიძლიათ იმუშაოთ;
- `su` &mdash; სერვისის მომხმარებლის სახელი;
- `sp` &mdash; სერვისის მომხმარებლის პაროლი.

თქვენი ორგანიზაციის მომხმარებელთა სიის სანახავად გამოიყენეთ `get_service_users` მეთოდი:

```ruby
users = RS.get_service_users(params)
```

პარამეტრებში უნდა გადაეცეს შემდეგი მონაცემები:

- `user_name` &mdash; თქვენი ორგანიზაციის მომხმარებლის სახელი;
- `user_password` &mdash; თქვენი ორგანიზაციის პაროლი.

ეს ფუნქცია აბრუნებს `RS::User` ტიპის (მომხმარებლის კლასი) ობიექტების მასივს.

ბოლო სასარგებლო სისტემური ფუნქციაა `get_name_from_tin`, რომლის დახმარებით შეგიძლიათ ორგანიზაციის საიდენტიფიკაციო ნომრიდან (ან პირადი ნომრიდან) მიიღოთ ამ ორგანიზაციის (პირის) დასახელება.

```ruby
name = RS.get_name_from_tin(params)
```

- `su` &mdash; სერვისის მომხმარებლის სახელი;
- `sp` &mdash; სერვისის მომხმარებლის პაროლი;
- `tin` &mdash; საიდენტიფიკაციო ნომერი ან პირადი ნომერი.

## ცნობარის ფუნქციები

TODO:

## ზედნადებთან მუშაობა

TODO: