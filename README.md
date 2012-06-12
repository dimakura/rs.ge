# RS.GE web services

This is a tiny API for working with [rs.ge](http://eservices.rs.ge) web-services in Ruby.

## Configuration

Configuration is done using `RS.config` object.
You can predefine `su` and `sp` parameters (*service user* name and password),
which are required in almost every API call for authentication:

```ruby
# configure service
RS.config.su = 'my_service_username'
RS.config.sp = 'my_service_password'
```

There is one more option, which can be used for configuration. Namely, `validate_remote` flag,
which indicates if TIN numbers are validated remotely when a waybill is validated.

```ruby
# validate remotes (the default is false)
RS.config.validate_remote = true
```

It's recommended to have this flag on `true`, unless performance considerations require the oposite.

## System methods

The simplest method to use is `what_is_my_ip`, which returns your outer IP address.
You'll need this IP address, when registering service user (see below):

```ruby
ip = RS.sys.what_is_my_ip
```

Before you can work with main API functions, you need to create a special user
(which is called *service user*). Use `create_user` method for this purpose:

```ruby
created = RS.sys.create_user(username: 'your_rs.ge_username', password: 'secret', ip: 'access_ip', name: 'name_of_this_user/ip_pair', su: 'new_user', sp: 'new_password'))
```

All parameters in the example above are required. The method returns `true` if the user creation was successfull.

When you need to update your user (including password change), `update_user` method should be used:

```ruby
updated = RS.sys.update_user(username: 'your_rs.ge_username', password: 'secret', ip: 'access_ip', name: 'name_of_this_user/ip_pair', su: 'new_user', sp: 'new_password'))
```

Checking of username/password can be done using `check_user` method:

```ruby
resp = RS.sys.check_user(su: 'service_user', sp: 'password')
```

If the username/passowrd pair is correct, the following hash is returned:

```ruby
{payer: payer_id, user: user_id}
```

where `payer` is the unique ID of the payer, whom this user belongs to, and  `user` gives ID of the user itself.
