# FrOData - Free OData V4.0 library for Ruby

### Happy Little Entities

<img src="images/bob-ross.jpg" alt="Bob Ross" width="192" height="192" align="right">

The FrOData gem provides a simple wrapper around the OData Version 4.0 API protocol.
It has the ability to automatically inspect compliant APIs and expose the relevant Ruby objects dynamically.

Features include:

A clean and modular architecture using Faraday middleware responses.

- Support for interacting with multiple users from different orgs.
- Support for schema discovery.
- Support for queryable interface.
- Support for GZIP compression.
- Support for Oauth authentication.

**This gem supports [OData Version 4.0](http://www.odata.org/documentation/). Support for older versions is not a goal.**

If you need a gem to integration with OData Version 3, you can use James Thompson's [original OData gem][ruby-odata], upon which this gem is based. It is also is based on a Fork from (https://github.com/wrstudios/frodata) who was an attempt to OData Version 4 but seemed unfinished. Finally
it uses code taken from Restforce for the client [Restforce gem](https://github.com/restforce/restforce)

[![Gem Version](https://badge.fury.io/rb/frodata.svg)](https://badge.fury.io/rb/frodata)
[![Build Status](https://app.codeship.com/projects/da1eb540-ce3f-0135-2ddc-161d5c3cc5fd/status?branch=master)](https://app.codeship.com/projects/262148)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2425311d859408ef8798/test_coverage)](https://codeclimate.com/github/wrstudios/frodata/test_coverage)

## Installation

Add this line to your application's `Gemfile`:

    gem 'frodata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frodata

This gem is versioned using [Semantic Versioning](http://semver.org/), so you can be confident when updating that there will not be breaking changes outside of a major version (following format MAJOR.MINOR.PATCH, so for instance moving from 3.1.0 to 4.0.0 would be allowed to include incompatible API changes). See the [changelog](https://github.com/restforce/restforce/tree/master/CHANGELOG.md) for details on what has changed in each version.

## Usage

Which authentication method you use really depends on your use case. If you're
building an application where many users from different orgs are authenticated
through oauth and you need to interact with data in their org on their behalf,
you should use the OAuth token authentication method.

This is currently the only supported method. This may change overtime

It is also important to note that the client object should not be reused across different threads, otherwise you may encounter [thread-safety issues](https://www.youtube.com/watch?v=p5zQOkyCACc).

#### OAuth token authentication

```ruby
client = FrOData.new(oauth_token: 'access_token',
                     instance_url: 'instance url',
                     base_path: '/path/to/service')
```

Although the above will work, you'll probably want to take advantage of the (re)authentication middleware by specifying `refresh_token`, `client_id`, `client_secret`, and `authentication_callback`:

```ruby
client = FrOData.new(oauth_token: 'access_token',
                     refresh_token: 'refresh token',
                     instance_url: 'instance url',
                     client_id: 'client_id',
                     client_secret: 'client_secret',
                     authentication_callback: Proc.new { |x| Rails.logger.debug x.to_s },
                     base_path: '/path/to/service')
```

The middleware will use the `refresh_token` automatically to acquire a new `access_token` if the existing `access_token` is invalid.

`authentication_callback` is a proc that handles the response from Salesforce when the `refresh_token` is used to obtain a new `access_token`. This allows the `access_token` to be saved for re-use later - otherwise subsequent API calls will continue the cycle of "auth failure/issue new access_token/auth success".

The proc is passed one argument, a `Hash` of the response, similar than the one for [Dynamics API](https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-protocols-oauth-code#refreshing-the-access-tokens):

```ruby
{
  "token_type"=>"Bearer",
  "scope"=>"user_impersonation",
  "expires_in"=>"3600",
  "ext_expires_in"=>"3600",
  "expires_on"=>"1552087545",
  "not_before"=>"1552083645",
  "resource"=>"https://myinstance.crm.dynamics.com",
  "access_token"=>"token",
  "refresh_token"=>"refresh token"
}
```

The `id` field can be used to [uniquely identify](https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-protocols-oauth-code#refreshing-the-access-tokens) the user that the `access_token` and `refresh_token` belong to.

### Proxy Support

You can specify a HTTP proxy using the `proxy_uri` option, as follows, or by setting the `FRODATA_PROXY_URI` environment variable:

```ruby
client = FrOData.new(username: 'foo',
                       password: 'bar',
                       security_token: 'security token',
                       client_id: 'client_id',
                       client_secret: 'client_secret',
                       proxy_uri: 'http://proxy.example.com:123',
                       base_path: '/path/to/service')
```

You may specify a username and password for the proxy with a URL along the lines of 'http://user:password@proxy.example.com:123'.

#### Global configuration

You can set any of the options passed into `FrOData.new` globally:

```ruby
FrOData.configure do |config|
  config.client_id     = 'foo'
  config.client_secret = 'bar'
end
```

### Bang! methods

All the CRUD methods (`create`, `update`, `upsert`, `destroy`) have equivalent methods with
a ! at the end (`create!`, `update!`, `upsert!`, `destroy!`), which can be used if you need
to do some custom error handling. The bang methods will raise exceptions, while the
non-bang methods will return false in the event that an exception is raised. This
works similarly to ActiveRecord.

### Custom Headers

You service may need custom headers. FrOData allows the addition of
custom headers in REST API requests to trigger specific logic. In order to pass any custom headers along with API requests,
you can specify a hash of `:request_headers` upon client initialization. The example below demonstrates how
to include the `myheader` header in all client HTTP requests:

```ruby
client = FrOData.new(oauth_token: 'access_token',
                       instance_url: 'instance url',
                       request_headers: { 'myheader' => 'FALSE' })

```

## Client API

### metadata

This will provide the XML schema for the service. This is also called automatically the first time you access most of the api in the client and cached in memory. For better performance, see the section below on [Services & the Service Registry](#)

```ruby
# Get the global describe for all sobjects
client.metadata
# => <xml>...</xml>

```

### Queries

Queries in general can be speficied directly as a string as such

or you can use the `FrOData::Query`. `FrOData::Query` instances form the base for finding specific entities within an `FrOData::EntitySet`.
A query object exposes a number of capabilities based on
the [System Query Options](http://docs.oasis-open.org/odata/odata/v4.0/errata03/os/complete/part1-protocol/odata-v4.0-errata03-os-part1-protocol-complete.html#_Toc453752288) provided for in the OData V4.0 specification.
Below is just a partial example of what is possible:

```ruby
  query = client.service['Products'].query
  query.where(query[:Price].lt(15))
  query.where(query[:Rating].gt(3))
  query.limit(3)
  query.skip(2)
  query.order_by("Name")
  query.select("Name,CreatedBy")
  query.inline_count
  results = query.execute
  results.each {|product| puts product['Name']}
```

The process of querying is kept purposely verbose to allow for lazy behavior to be implemented at higher layers.
Internally, `FrOData::Query` relies on the `FrOData::Query::Criteria` for the way the `where` method works.
You should refer to the published RubyDocs for full details on the various capabilities:

- [FrOData::Query](http://rubydoc.info/github/wrstudios/frodata/master/FrOData/Query)
- [FrOData::Query::Criteria](http://rubydoc.info/github/wrstudios/frodata/master/FrOData/Query/Criteria)

[odata-facets]: http://docs.oasis-open.org/odata/odata/v4.0/errata03/os/complete/part3-csdl/odata-v4.0-errata03-os-part3-csdl-complete.html#_Toc453752528
[odata-ops]: http://docs.oasis-open.org/odata/odata/v4.0/errata03/os/complete/part1-protocol/odata-v4.0-errata03-os-part1-protocol-complete.html#_Toc453752307

```ruby
products = client.query("Products?$filter=name eq 'somename'")
# => [#<FrOData::Entity>]

# or the equivalent using a query object
query_object = client.service['Products'].query
query_object.where("name eq 'yo'")
products = client.query(query_object)
# => [#<FrOData::Entity>]
```

### Find

```ruby
# Select an account from an Accounts set with primary key set to '001D000000INjVe'

client.find('Accounts', '001D000000INjVe')
# => #<FrOData::Entity accountid="001D000000INjVe" name="Test" ... >
```

### select

`select` allows the fetching of a specific list of fields from a single object. Only selected fields will be populated is much faster.

```ruby
# Select the `name` column from an Account entity in the Accounts set with primary key set to '001D000000INjVe'

client.select('Accounts', '001D000000INjVe', ["name"])
# => # => #<FrOData::Entity accountid="001D000000INjVe" name="Name" other_field="nil" ... >

```

### create

```ruby
# Add a new account
client.create('Accounts', Name: 'Foobar Inc.')
# => '0016000000MRatd'
```

### update

```ruby
# Update the Account with `Id` '0016000000MRatd'
client.update('Accounts', Id: '0016000000MRatd', Name: 'Whizbang Corp')
# => true
```

### destroy

```ruby
# Delete the Account with `Id` '0016000000MRatd'
client.destroy('Accounts', '0016000000MRatd')
# => true
```

#### Count

```ruby
  client.count('Accounts')
  # => 3
```

### Services & the Service Registry

The FrOData gem provides a number of core classes, the two most basic ones are the `FrOData::Service` and the `FrOData::ServiceRegistry`.
The only time you will need to worry about the `FrOData::ServiceRegistry` is when you have multiple FrOData
services you are interacting with that you want to keep straight easily.
The nice thing about `FrOData::Service` is that it automatically registers with the registry on creation, so there is no manual interaction with the registry necessary.

To create an `FrOData::Service` simply provide the location of a service endpoint to it like this:

```ruby
  FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc')
```

You may also provide an options hash after the URL.
It is suggested that you supply a name for the service via this hash like so:

```ruby
  FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
```

For more information regarding available options and how to configure a service instance, refer to [Service Configuration](#service-configuration) below.

This one call will setup the service and allow for the discovery of everything the other parts of the FrOData gem need to function.
The two methods you will want to remember from `FrOData::Service` are `#service_url` and `#name`.
Both of these methods are available on instances and will allow for lookup in the `FrOData::ServiceRegistry`, should you need it.

Using either the service URL or the name provided as an option when creating an `FrOData::Service` will allow for quick lookup in the `FrOData::ServiceRegistry` like such:

```ruby
  FrOData::ServiceRegistry['http://services.odata.org/V4/OData/OData.svc']
  FrOData::ServiceRegistry['ODataDemo']
```

Both of the above calls would retrieve the same service from the registry.
At the moment there is no protection against name collisions provided in `FrOData::ServiceRegistry`.
So, looking up services by their service URL is the most exact method, but lookup by name is provided for convenience.

### Service Configuration

#### Metadata File

Typically the metadata file of a service can be quite large.
You can speed your load time by forcing the service to load the metadata from a file rather than a URL.
This is only recommended for testing purposes, as the metadata file can change.

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', {
    name: 'ODataDemo',
    metadata_file: "metadata.xml",
  })
```

#### Metadata Data

Typically the metadata file of a service can be quite large.
You can speed your load time by forcing the service to load the metadata from a file rather than a URL.
This is only recommended for testing purposes, as the metadata file can change.

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', {
    name: 'ODataDemo',
    metadata_data: "metadata.xml",
  })
```

### Exploring a Service

Once instantiated, you can request various information about the service, such as the names and types of entity sets it exposes, or the names of the entity types (and custom datatypes) it defines.

For example:

Get a list of available entity types

```ruby
  client.service.entity_types
  # => [
  #   "ODataDemo.Product",
  #   "ODataDemo.FeaturedProduct",
  #   "ODataDemo.ProductDetail",
  #   "ODataDemo.Category",
  #   "ODataDemo.Supplier",
  #   "ODataDemo.Person",
  #   "ODataDemo.Customer",
  #   "ODataDemo.Employee",
  #   "ODataDemo.PersonDetail",
  #   "ODataDemo.Advertisement"
  # ]
```

Get a list of entity sets

```ruby
  client.service.entity_sets
  # => {
  #   "Products"       => "ODataDemo.Product",
  #   "ProductDetails" => "ODataDemo.ProductDetail",
  #   "Categories"     => "ODataDemo.Category",
  #   "Suppliers"      => "ODataDemo.Supplier",
  #   "Persons"        => "ODataDemo.Person",
  #   "PersonDetails"  => "ODataDemo.PersonDetail",
  #   "Advertisements" => "ODataDemo.Advertisement"
  # }
```

Get a list of complex types

```ruby
  client.service.complex_types
  # => ["ODataDemo.Address"]
```

Get a list of enum types

```ruby
  client.service.enum_types
  # => ["ODataDemo.ProductStatus"]
```

For more examples, refer to [usage_example_specs.rb](spec/frodata/usage_example_specs.rb).

### Entity Sets

When it comes to reading data from an OData service the most typical way will be via `FrOData::EntitySet` instances.
Under normal circumstances you should never need to worry about an `FrOData::EntitySet` directly.
For example, to get an `FrOData::EntitySet` for the products in the ODataDemo service simply access the entity set through the service like this:

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc')
  products = service['ProductsSet'] # => FrOData::EntitySet
```

You can get a list of all your entity sets like this:

```ruby
  service.entity_sets
```

### Entities

`FrOData::Entity` instances represent individual entities, or records, in a given service.
They are returned primarily through interaction with instances of `FrOData::EntitySet`.
You can access individual properties on an `FrOData::Entity` like so:

```ruby
  product = products.first # => FrOData::Entity
  product['Name']  # => 'Bread'
  product['Price'] # => 2.5 (Float)
```

Individual properties on an `FrOData::Entity` are automatically typecast by the gem, so you don't have to worry about too much when working with entities.

You can get a list of all your entities like this:

```ruby
  service.entity_types
```

#### Entity Properties

Reading, parsing and instantiating all properties of an entity can add up to a significant amount of time, particularly for those entities with a large number of properties.
To speed this process up all properties are lazy loaded.
Which means it will store the name of the property, but will not parse and instantiate the property until you want to use it.

You can find all the property names of your entity with

```ruby
  product.property_names
```

You can grab the parsed value of the property as follows:

```ruby
  product["Name"]
```

or, you can get a hold of the property class instance using

```ruby
  product.get_property("Name")
```

This will parse and instantiate the property if it hasn't done so yet.

##### Lenient Property Validation

By default, we use strict property validation, meaning that any property validation errors in the data will raise an exception.
However, you may encounter OData implementations in the wild that break the specs in strange and surprising ways (shocking, I know!).

Since it's often better to get _some_ data instead of nothing at all, you can optionally make the property validation lenient.
Simply add `strict: false` to the service constructor options.
In this mode, any property validation error will log a warning instead of raising an exception. The corresponding property value will be `nil` (even if the property is declared as not allowing NULL values).

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', strict: false)
  # -- alternatively, for an existing service instance --
  service.options[:strict] = false
```

## Contributing

1. Fork it (`https://github.com/[my-github-username]/frodata/fork`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits

Many thanks go to [James Thompson][@plainprogrammer], who wrote the [original OData (Version 3.0) gem][ruby-odata].

[@plainprogrammer]: https://github.com/plainprogrammer
[ruby-odata]: https://github.com/ruby-odata/odata

Many thanks go to [James Thompson][@pandawhisperer], who started the work on the [OData (Version 4.0) gem][frodata].

[@plainprogrammer]: https://github.com/PandaWhisperer
[frodata]: https://github.com/wrstudios/frodata

Also, I would like to thank [Outreach][outreach] for generously allowing me to work on Open Source software like this. If you want to work on interesting challenges with an awesome team, check out our [open positions][outreachcareers].

[outreach]: http://outreach.io/
[outreachcareers]: http://outreach.io/careers
