# BeValid

BeValid is a custom ActiveModel / Rails validator that helps with "conditional" validation. IE you can setup field-level validations that depend
upon complex state within the object.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'be_valid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install be_valid

## Usage

Examples:

```ruby
class Account
  validates :email, 
    must_be: {
      present: true,
      when: {
        status: 'active'
      }
    }
 
  validates :birthdate,
    must_be: {
      before: -> { 18.years.ago }
    },
    when: {
      account_type: :adult?
    }

    validates :open_date, date: {time: true, before: :now}

    validates :late_fee,
      must_be: { 
        equal_to: 0,
        when: { 
          status: 'current',
          customer_type: :premier? 
        },
        rule_name: :premier_customer_waived_fee
      },
      allow_blank: true

end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
