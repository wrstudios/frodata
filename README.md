# FrOData - Free OData V4.0 library for Ruby

### Happy Little Entities

<img src="images/bob-ross.jpg" alt="Bob Ross" width="192" height="192" align="right">

The FrOData gem provides a simple wrapper around the OData Version 4.0 API protocol.
It has the ability to automatically inspect compliant APIs and expose the relevant Ruby objects dynamically.
It also provides a set of code generation tools for quickly bootstrapping more custom service libraries.

**This gem supports [OData Version 4.0](http://www.odata.org/documentation/). Support for older versions is not a goal.**

If you need a gem to integration with OData Version 3, you can use James Thompson's [original OData gem][ruby-odata], upon which this gem is based.

[![Gem Version](https://badge.fury.io/rb/frodata.svg)](https://badge.fury.io/rb/frodata)
[![Build Status](https://app.codeship.com/projects/da1eb540-ce3f-0135-2ddc-161d5c3cc5fd/status?branch=master)](https://app.codeship.com/projects/262148)
[![Maintainability](https://api.codeclimate.com/v1/badges/2425311d859408ef8798/maintainability)](https://codeclimate.com/github/wrstudios/frodata/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2425311d859408ef8798/test_coverage)](https://codeclimate.com/github/wrstudios/frodata/test_coverage)
[![Documentation](http://inch-ci.org/github/wrstudios/frodata.png?branch=master)](http://www.rubydoc.info/github/wrstudios/frodata/master)

## Installation

Add this line to your application's `Gemfile`:

    gem 'frodata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frodata

## Usage

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

#### Headers & Authorization

The OData protocol does not deal with authentication and authorization at all, nor does it need to, since [HTTP already provides many different options][http-auth] for this, such as HTTP Basic or token authorization.
Hence, this gem does not implement any special authentication mechanisms either, and relies on the underlying HTTP library ([Faraday][faraday]) to take care of this.

##### Setting Custom Headers

You can customize request headers with the **:connection** option key.
This allows you to e.g. set custom headers (such as `Authorization`) that may be required by your service.

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', {
    name: 'ODataDemo',
    connection: {
      headers: {
        "Authorization" => "Bearer #{access_token}"
      }
    }
  })
```

##### Using Authentication Helpers

You may also set up authorization by directly accessing the underlying `Faraday::Connection` object `yield`ed to the constructor (as explained in [Advanced Customization](#advanced-connection-customization) below).
This allows you to make use of Faraday's [authentication helpers][faraday-auth], such as `basic_auth` or `token_auth`.

For instance, if your service requires HTTP basic authentication:

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', {
    name: 'ODataDemo'
  }) do |conn|
    conn.request(:authorization, :basic, 'username', 'password')
  end
```

[http-auth]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication
[faraday]: https://github.com/lostisland/faraday
[faraday-auth]: https://github.com/lostisland/faraday/blob/main/docs/middleware/request/authentication.md

#### Advanced Connection Customization

Under the hood, the gem uses the [Faraday][faraday] HTTP library to provide flexible
integration of various Ruby HTTP backends.

There are several ways to access the underlying `Faraday::Connection`:

##### As a service option

If you already have a `Faraday::Connection` instance that you want the service to use, you can simply pass it to the constructor *instead* of the service URL as first parameter.
In this case, you'll be setting the service URL on the connection object, as shown below:

```ruby
  conn = Faraday.new('http://services.odata.org/V4/OData/OData.svc') do |conn|
    # ... customize connection ...
  end

  service = FrOData::Service.new(conn, name: 'ODataDemo')
```

**NOTE**: if you use this method, any options set via the `:connection` options key will be ignored.

##### Passing a block to the constructor

Alternatively, the connection object is also `yield`ed by the constructor, so you may customize it by passing a block argument.
For instance, if you wanted to use [Typhoeus][typhoeus] as your HTTP library:

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', {
    name: 'ODataDemo'
  }) do |conn|
    conn.adapter :typhoeus
  end
```

[typhoeus]: https://github.com/typhoeus/typhoeus

### Exploring a Service

Once instantiated, you can request various information about the service, such as the names and types of entity sets it exposes, or the names of the entity types (and custom datatypes) it defines.

For example:

Get a list of available entity types

```ruby
  service.entity_types
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
  service.entity_sets
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
  service.complex_types
  # => ["ODataDemo.Address"]
```

Get a list of enum types

```ruby
  service.enum_types
  # => ["ODataDemo.ProductStatus"]
```

For more examples, refer to [usage_example_spec.rb](spec/frodata/usage_example_spec.rb).


### Entity Sets

When it comes to reading data from an OData service the most typical way will be via `FrOData::EntitySet` instances.
Under normal circumstances you should never need to worry about an `FrOData::EntitySet` directly.
For example, to get an `FrOData::EntitySet` for the products in the ODataDemo service simply access the entity set through the service like this:

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc')
  products = service['ProductsSet'] # => FrOData::EntitySet
```

`FrOData::EntitySet` instances implement the `Enumerable` module, meaning you can work with them very naturally, like this:

```ruby
  products.each do |entity|
    entity # => FrOData::Entity for type Product
  end
```

You can get a list of all your entity sets like this:

```ruby
  service.entity_sets
```

#### Count
Some versions of Microsoft CRM do not support count.

```ruby
  products.count
```

#### Collections
You can you the following methods to grab a collection of Entities:

```ruby
  products.each do |entity|
    ...
  end
```

The first entity object returns a single entity object.

```ruby
  products.first
```

`first(x)` returns an array of entity objects.

```ruby
  products.first(x)
```

#### Find a certain Entity

```ruby
  service['ProductsSet']['<primary key of entity>']
```

With certain navigation properties expanded (i.e. eagerly loaded):

```ruby
  # Eagerly load a single navigation property
  service['ProductsSet', expand: 'Categories']

  # Eagerly load multiple navigation properties
  service['ProductsSet', expand: ['Categories', 'Supplier']]

  # Eagerly load ALL navigation properties
  service['ProductsSet', expand: :all]
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
The way this is implemented internally guarantees that an `FrOData::Entity` is always ready to save back to the service or `FrOData::EntitySet`, which you do like so:

```ruby
  service['Products'] << product # Write back to the service
  products << product        # Write back to the Entity Set
```

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

Since it's often better to get *some* data instead of nothing at all, you can optionally make the property validation lenient.
Simply add `strict: false` to the service constructor options.
In this mode, any property validation error will log a warning instead of raising an exception. The corresponding property value will be `nil` (even if the property is declared as not allowing NULL values).

```ruby
  service = FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', strict: false)
  # -- alternatively, for an existing service instance --
  service.options[:strict] = false
```

### Queries

`FrOData::Query` instances form the base for finding specific entities within an `FrOData::EntitySet`.
A query object exposes a number of capabilities based on
the [System Query Options](http://docs.oasis-open.org/odata/odata/v4.0/errata03/os/complete/part1-protocol/odata-v4.0-errata03-os-part1-protocol-complete.html#_Toc453752288) provided for in the OData V4.0 specification.
Below is just a partial example of what is possible:

```ruby
  query = service['Products'].query
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

 * [FrOData::Query](http://rubydoc.info/github/wrstudios/frodata/master/FrOData/Query)
 * [FrOData::Query::Criteria](http://rubydoc.info/github/wrstudios/frodata/master/FrOData/Query/Criteria)

[odata-facets]: http://docs.oasis-open.org/odata/odata/v4.0/errata03/os/complete/part3-csdl/odata-v4.0-errata03-os-part3-csdl-complete.html#_Toc453752528
[odata-ops]: http://docs.oasis-open.org/odata/odata/v4.0/errata03/os/complete/part1-protocol/odata-v4.0-errata03-os-part1-protocol-complete.html#_Toc453752307

## Contributing

1. Fork it (`https://github.com/[my-github-username]/odata/fork`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits

Many thanks go to [James Thompson][@plainprogrammer], who wrote the [original OData (Version 3.0) gem][ruby-odata].

[@plainprogrammer]: https://github.com/plainprogrammer
[ruby-odata]: https://github.com/ruby-odata/odata

Also, I would like to thank [W+R Studios][wrstudios] for generously allowing me to work on Open Source software like this. If you want to work on interesting challenges with an awesome team, check out our [open positions][wrcareers].

[wrstudios]: http://wrstudios.com/
[wrcareers]: http://wrstudios.com/careers
