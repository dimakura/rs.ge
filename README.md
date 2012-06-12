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

## Dictionary Calls

You can get *units* using `units` method on dictionary object:

```ruby
units = RS.dict.units(su: su, sp: sp) # => returns {id: name} hash of units
```

Transport and waybill types can be obtained in the same way:

```ruby
transport_types = RS.dict.transport_types(su: su, sp: sp) # => {id: name}
waybill_types   = RS.dict.waybill_types(su: su, sp: sp)   # => {id: name}
```

It should be noted, that transport and waybill types can be obtained without calling
those remote method, by simply taking `RS::TRANSPORT_TYPES` and `RS::WAYBILL_TYPES`
constants. This constants represent the current (relativly unchanged) set of
transport and waybill types and may be changed by Revenue Service in the future.
We'll try to update them accordingly, but there is no guarantee on exact match.

The last method of `RS.dict` method is usefull for obtaining name of the
person/organization by its TIN-number:

```ruby
name = RS.dict.get_name_from_tin(tin: '02001000490') # => 'დიმიტრი ყურაშვილი'
```

> Note, that we didn't used `su` and `sp` parameters in the last method call,
> while we suppose they were predefined in `RS.config` object (see configuration section).