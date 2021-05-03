require "test_helper"
require 'validators/must_be_validator'


class MustBeValidatorTest < Minitest::Test
  describe "validate_each" do
    it "raises an error if there's no matcher" do
      clazz = Class.new(User) do
        validates :name, must_be: {}
      end
      instance = clazz.new(name: 'foo', email: 'foo')
      assert_raises do
        instance.valid?
      end
    end
    it "allows rules to be disabled via the config" do
      clazz = Class.new(User) do
        validates :name, must_be: {blank: true, rule_name: :foo}
      end
      instance = clazz.new(name: 'foo', email: 'foo')
      refute instance.valid?
      BeValid.configure do |config|
        config.rules[:foo] = {disabled: true}
      end
      assert instance.valid?
    end
    describe "blank" do
      let(:clazz) do
        Class.new(User) do
          validates :name, must_be: { blank: true }
        end
      end

      it "doesnt add an error if the attribute is empty string" do
        instance = clazz.new(name: '')
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "doesnt add an error if the attribute is nil" do
        instance = clazz.new(name: nil)
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "shows error if there's a value" do
        instance = clazz.new(name: 'foo')
        refute instance.valid?
        assert_equal ["Name must be blank."], instance.errors.full_messages
      end
    end

    describe "present" do
      let(:clazz) do
        Class.new(User) do
          validates :name, must_be: { present: true }
        end
      end
      it "doesnt add an error if the attribute is there" do
        instance = clazz.new(name: 'foo')
        assert instance.valid?
        assert instance.errors.empty?, instance.errors.full_messages
      end

      it "adds an error if the attribute is nil" do
        instance = clazz.new(name: nil)
        refute instance.valid?
        assert_equal ["Name must be present."], instance.errors.full_messages
      end

      it "shows an error if attribute is an empty string" do
        instance = clazz.new(name: '')
        refute instance.valid?
        assert_equal ["Name must be present."], instance.errors.full_messages
      end

      it "shows no error if attribute is zero" do
        clazz = Class.new(User) do
          validates :salary, must_be: { present: true }
        end
        instance = clazz.new(salary: 0)
        assert instance.valid?
        assert instance.errors.empty?
      end
    end

    describe "equal_to" do
      let(:clazz) do
        Class.new(User) do
          validates :name, must_be: { equal_to: 'foo'}
        end
      end
      it "doesnt add an error if the attribute equal" do
        instance = clazz.new(name: 'foo')
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "adds an error if not equal" do
        instance = clazz.new(name: 'bar')
        refute instance.valid?
        assert_equal ["must be equal to foo."], instance.errors[:name]
      end
      it "adds an error if predicate is nil" do
        instance = clazz.new(name: nil)
        refute instance.valid?
        assert_equal ["must be equal to foo."], instance.errors[:name]
      end
      it "can compare to other fields in model" do
        clazz = Class.new(User) do
          validates :name, must_be: {equal_to: :email}
        end
        instance = clazz.new(name: 'foo', email: 'foo')
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
        instance = clazz.new(name: 'bar', email: 'foo')
        refute instance.valid?
        assert_equal ["must be equal to email."], instance.errors[:name]
      end
    end

    describe "greater_than" do
      let(:clazz) do
        Class.new(User) do
          validates :salary, must_be: { greater_than: 10}
        end
      end
      it "doesnt add an error if the attribute greater than" do
        instance = clazz.new(salary: 11)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "adds an error if equal" do
        instance = clazz.new(salary: 10)
        refute instance.valid?
        assert_equal ["must be greater than 10."], instance.errors[:salary]
      end
      it "adds an error if predicate is nil" do
        instance = clazz.new(name: nil)
        refute instance.valid?
        assert_equal ["must be greater than 10."], instance.errors[:salary]
      end
      it "can compare to other fields in model" do
        clazz = Class.new(User) do
          validates :salary, must_be: {greater_than: :bonus}
        end
        instance = clazz.new(salary: 20, bonus: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
        instance = clazz.new(salary: 0, bonus: 10)
        refute instance.valid?
        assert_equal ["must be greater than bonus."], instance.errors[:salary]
      end
    end

    describe "greater_or_equal_to" do
      let(:clazz) do
        Class.new(User) do
          validates :salary, must_be: { greater_or_equal_to: 10}
        end
      end
      it "doesnt add an error if the attribute greater or equal to" do
        instance = clazz.new(salary: 11)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "is valid if equal" do
        instance = clazz.new(salary: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "adds an error if predicate is nil" do
        instance = clazz.new(name: nil)
        refute instance.valid?
        assert_equal ["must be greater or equal to 10."], instance.errors[:salary]
      end
      it "can compare to other fields in model" do
        clazz = Class.new(User) do
          validates :salary, must_be: {greater_or_equal_to: :bonus}
        end
        instance = clazz.new(salary: 20, bonus: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
        instance = clazz.new(salary: 0, bonus: 10)
        refute instance.valid?
        assert_equal ["must be greater or equal to bonus."], instance.errors[:salary]
      end
    end

    describe "less_or_equal_to" do
      let(:clazz) do
        Class.new(User) do
          validates :salary, must_be: { less_or_equal_to: 10}
        end
      end
      it "doesnt add an error if the attribute greater or equal to" do
        instance = clazz.new(salary: 9)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "is valid if equal" do
        instance = clazz.new(salary: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "adds an error if predicate is nil" do
        instance = clazz.new(name: nil)
        refute instance.valid?
        assert_equal ["must be less or equal to 10."], instance.errors[:salary]
      end
      it "can compare to other fields in model" do
        clazz = Class.new(User) do
          validates :salary, must_be: {less_or_equal_to: :bonus}
        end
        instance = clazz.new(salary: 2, bonus: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
        instance = clazz.new(salary: 10, bonus: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
        instance = clazz.new(salary: 20, bonus: 10)
        refute instance.valid?
        assert_equal ["must be less or equal to bonus."], instance.errors[:salary]
      end
    end

    describe "less_than" do
      let(:clazz) do
        Class.new(User) do
          validates :salary, must_be: { less_than: 10}
        end
      end
      it "doesnt add an error if the attribute greater or equal to" do
        instance = clazz.new(salary: 9)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "is invalid if equal" do
        instance = clazz.new(salary: 10)
        refute instance.valid?
        assert_equal ["must be less than 10."], instance.errors[:salary]
      end
      it "adds an error if predicate is nil" do
        instance = clazz.new(name: nil)
        refute instance.valid?
        assert_equal ["must be less than 10."], instance.errors[:salary]
      end
      it "can compare to other fields in model" do
        clazz = Class.new(User) do
          validates :salary, must_be: {less_than: :bonus}
        end
        instance = clazz.new(salary: 2, bonus: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
        instance = clazz.new(salary: 20, bonus: 10)
        refute instance.valid?
        assert_equal ["must be less than bonus."], instance.errors[:salary]
      end
    end

    describe "not_equal_to" do
      let(:clazz) do
        Class.new(User) do
          validates :salary, must_be: { not_equal_to: 10}
        end
      end
      it "doesnt add an error if the attribute not equal to" do
        instance = clazz.new(salary: 9)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "is invalid if equal" do
        instance = clazz.new(salary: 10)
        refute instance.valid?
        assert_equal ["must be not equal to 10."], instance.errors[:salary]
      end
      it "is valid if subject is nil and predicate is not" do
        instance = clazz.new(salary: nil)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
      it "can compare to other fields in model" do
        clazz = Class.new(User) do
          validates :salary, must_be: {not_equal_to: :bonus}
        end
        instance = clazz.new(salary: 10, bonus: 10)
        refute instance.valid?
        assert_equal ["must be not equal to bonus."], instance.errors[:salary]
        instance = clazz.new(salary: 20, bonus: 10)
        assert instance.valid?, instance.errors.full_messages
        assert instance.errors.empty?, instance.errors.full_messages
      end
    end

    describe "matching" do
      let(:clazz) do
        Class.new(User) do
          validates :name, must_be: { matching: /strange.*love/}
        end
      end
      it "doesnt add an error if the attribute is matching" do
        instance = clazz.new(name: 'strangelove')
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(name: 'strange love')
        assert instance.valid?
        assert instance.errors.empty?
      end
      it "shows error if value doesnt match regex" do
        instance = clazz.new(name: 'foo')
        refute instance.valid?
        assert_equal ["Name must be matching /strange.*love/."], instance.errors.full_messages
      end
    end

    describe "one_of" do
      let(:clazz) do
        Class.new(User) do
          validates :bonus, must_be: { one_of: [1,2,3] } 
        end
      end
      it "doesnt add an error if the attribute is in array" do
        instance = clazz.new(bonus: 2)
        assert instance.valid?
        assert instance.errors.empty?
      end
      it "allows arrays of arrays for the one_of values" do
        clazz = Class.new(User) do
          validates :bonus, must_be: { one_of: [[4,5],[1,2,3]], show_values: true}
        end
        instance = clazz.new(bonus: 5)
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(bonus: 73)
        refute instance.valid?
        assert_equal ["Bonus : '73.0' is not a valid value. Valid values: 4, 5, 1, 2, 3."], instance.errors.full_messages
      end
      it "shows error if value isnt in list" do
        instance = clazz.new(bonus: 7)
        refute instance.valid?
        assert_equal ["Bonus : '7.0' is not a valid value. Valid values: 1, 2, 3."], instance.errors.full_messages
      end
      it "shows error without valid options if show_values = false" do
        clazz = Class.new(User) do
          validates :bonus, must_be: { one_of: [1,2,3], show_values: false }
        end
        instance = clazz.new(bonus: 7)
        refute instance.valid?
        assert_equal ["Bonus : '7.0' is not a valid value."], instance.errors.full_messages
      end
    end

    describe "not_any_of" do
      let(:clazz) do
        Class.new(User) do
          validates :bonus, must_be: { not_any_of: [1,2,3] } 
        end
      end
      it "doesnt add an error if the attribute is NOT in array" do
        instance = clazz.new(bonus: 7)
        assert instance.valid?
        assert instance.errors.empty?
      end
      it "shows error if value IS in list" do
        instance = clazz.new(bonus: 2)
        refute instance.valid?
        assert_equal ["Bonus : '2.0' is not a valid value. Invalid values: 1, 2, 3."], instance.errors.full_messages
      end
      it "shows error without valid options if show_values = false" do
        clazz = Class.new(User) do
          validates :bonus, must_be: { not_any_of: [1,2,3], show_values: false }
        end
        instance = clazz.new(bonus: 2)
        refute instance.valid?
        assert_equal ["Bonus : '2.0' is not a valid value."], instance.errors.full_messages
      end
    end

    describe "only_from" do
      let(:clazz) do
        Class.new(User) do
          validates :letters, must_be: { only_from: %w(A B C) } 
        end
      end
      it "doesnt add an error if the attribute is single value in array" do
        instance = clazz.new(letters: 'A')
        assert instance.valid?
        assert instance.errors.empty?
      end
      it "shows error if value is array  with values NOT in list" do
        instance = clazz.new(letters: ['A', 'Z'])
        refute instance.valid?
        assert_equal ["Letters : ['A', 'Z'] is not a valid value. Valid values: A, B, C."], instance.errors.full_messages
      end
      it "shows error if value is single with value NOT in list" do
        instance = clazz.new(letters: 'Z')
        refute instance.valid?
        assert_equal ["Letters : Z is not a valid value. Valid values: A, B, C."], instance.errors.full_messages
      end
      it "shows error without valid options if show_values = false" do
        clazz = Class.new(User) do
          validates :letters, must_be: { only_from: %w(A B C), show_values: false } 
        end
        instance = clazz.new(letters: ['A', 'Z'])
        refute instance.valid?
        assert_equal ["Letters : ['A', 'Z'] is not a valid value."], instance.errors.full_messages
      end
    end

    describe "before" do
      let(:clazz) do
        Class.new(User) do
          validates :birthday, must_be: { before: Date.new(2020,01,01) }
        end
      end
      it "has no error if date is before or equal to predicate" do
        instance = clazz.new(birthday: Date.new(2019,01,01))
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(birthday: Date.new(2020,01,01))
        assert instance.valid?
        assert instance.errors.empty?
      end
      it "has an error if date is after predicate" do
        instance = clazz.new(birthday: Date.new(2021,01,01))
        refute instance.valid?
        assert_equal ["Birthday : 2021-01-01 is not a valid value. Date cannot be after 2020-01-01."], instance.errors.full_messages
      end

      describe "field comparison" do
        let(:clazz) do
          Class.new(User) do
            validates :birthday, must_be: { before: :naming_day }
          end
        end
        it "has an error if date is after other field" do
          instance = clazz.new(birthday: Date.new(2021,01,01), naming_day: Date.new(2020,01,01))
          refute instance.valid?
          assert_equal ["Birthday : 2021-01-01 is not a valid value. Date cannot be after naming_day."], instance.errors.full_messages
        end
        it "has NO error if date is equal to other field" do
          instance = clazz.new(birthday: Date.today, naming_day: Date.today)
          assert instance.valid?
          assert instance.errors.empty?
        end
      end


      describe ":now" do
        let(:clazz) do
          Class.new(User) do
            validates :birthday, must_be: { before: :now }
          end
        end
        it "has an error if date is after now" do
          instance = clazz.new(birthday: (Date.today + 10))
          refute instance.valid?
          assert_equal ["Birthday : #{(Date.today + 10)} is not a valid value. Date cannot be in the future."], instance.errors.full_messages
        end
        it "has NO error if date is equal to now" do
          instance = clazz.new(birthday: Time.now)
          assert instance.valid?
          assert instance.errors.empty?
        end
      end

      describe ":today" do
        let(:clazz) do
          Class.new(User) do
            validates :birthday, must_be: { before: :today }
          end
        end
        it "has an error if date is after today" do
          instance = clazz.new(birthday: (Date.today + 10))
          refute instance.valid?
          assert_equal ["Birthday : #{(Date.today + 10)} is not a valid value. Date cannot be in the future."], instance.errors.full_messages
        end
        it "has NO error if date is equal to today" do
          instance = clazz.new(birthday: Time.now)
          assert instance.valid?
          assert instance.errors.empty?
        end
      end

    end

    describe "after" do
      let(:clazz) do
        Class.new(User) do
          validates :birthday, must_be: { after: Date.new(2020,01,01) }
        end
      end
      it "has no error if date is after or equal to predicate" do
        instance = clazz.new(birthday: Date.new(2021,01,01))
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(birthday: Date.new(2020,01,01))
        assert instance.valid?
        assert instance.errors.empty?
      end
      it "has an error if date is before predicate" do
        instance = clazz.new(birthday: Date.new(2001,01,01))
        refute instance.valid?
        assert_equal ["Birthday : 2001-01-01 is not a valid value. Date cannot be before 2020-01-01."], instance.errors.full_messages
      end

      describe ":now" do
        let(:clazz) do
          Class.new(User) do
            validates :birthday, must_be: { before: :now }
          end
        end
        it "has an error if date is after now" do
          instance = clazz.new(birthday: (Date.today + 10))
          refute instance.valid?
          assert_equal ["Birthday : #{(Date.today + 10)} is not a valid value. Date cannot be in the future."], instance.errors.full_messages
        end
        it "has NO error if date is equal to now" do
          instance = clazz.new(birthday: Time.now)
          assert instance.valid?
          assert instance.errors.empty?
        end
      end
    end

    describe "when" do
      it "handles method call on condition" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {salary: :present?} }
        end
        instance = clazz.new(email: nil, salary: 10)
        refute instance.valid?
        assert_equal ["Email must be present when salary is present."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@bar.com', salary: 10)
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(email: nil, salary: nil)
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "handles :blank when predicate is nil" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {salary: :blank} }
        end
        instance = clazz.new(email: nil, salary: nil)
        refute instance.valid?
        assert_equal ["Email must be present when salary is blank."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@foo', salary: nil)
        assert instance.valid?
        instance = clazz.new(email: nil, salary: 20)
        assert instance.valid?
      end

      it "handles :present when predicate is nil" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {salary: :present} }
        end
        instance = clazz.new(email: nil, salary: 10)
        refute instance.valid?
        assert_equal ["Email must be present when salary is present."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@foo', salary: 20)
        assert instance.valid?
        instance = clazz.new(email: 'foo@foo', salary: nil)
        assert instance.valid?
      end


      it "handles value on condition" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {salary: 20} }
        end
        instance = clazz.new(email: nil, salary: 20)
        refute instance.valid?
        assert_equal ["Email must be present when salary = 20.0."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@bar.com', salary: 20)
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(email: nil, salary: 6)
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "handles method symbol on condition" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {status: :premium? } }
        end
        instance = clazz.new(email: nil, name: 'beyonce')
        refute instance.valid?
        assert_equal ["Email must be present when status is premium."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@bar.com', salary: 20)
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(email: nil, salary: 6)
        assert instance.valid?
        assert instance.errors.empty?
      end


      it "handles Regexp on condition" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {name: /dave.*/} }
        end
        instance = clazz.new(email: nil, name: 'dave t')
        refute instance.valid?
        assert_equal ["Email must be present when name = dave t."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@bar.com', name: 'dav')
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(email: nil, name: nil)
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "handles array on condition" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {name: ['Dave', 'Alice', 'Fred']} }
        end
        instance = clazz.new(email: nil, name: 'Alice')
        refute instance.valid?
        assert_equal ["Email must be present when name = Alice."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@bar.com', name: 'Fred')
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(email: nil, name: 'Rita')
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "handles array of arrays on condition" do
        clazz = Class.new(User) do
          validates :email, must_be: { present: true, when: {name: [['Dave'], ['Alice', 'Fred']]} }
        end
        instance = clazz.new(email: nil, name: 'Alice')
        refute instance.valid?
        assert_equal ["Email must be present when name = Alice."], instance.errors.full_messages
        instance = clazz.new(email: 'foo@bar.com', name: 'Fred')
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(email: nil, name: 'Rita')
        assert instance.valid?
        assert instance.errors.empty?
      end

      it "ANDing of multiples" do
        clazz = Class.new(User) do
          validates :email, 
            must_be: { 
              present: true, 
              when: {
                letters: 'abc',
                name: 'fred'
              } 
            }
        end
        instance = clazz.new(letters: 'abc', name: 'fred')
        refute instance.valid?
        assert_equal ["Email must be present when letters = abc and name = fred."], instance.errors.full_messages
        instance = clazz.new(letters: 'abc', name: 'fred', email: 'fred@foo')
        assert instance.valid?
        assert instance.errors.empty?
        instance = clazz.new(letters: 'abc', name: 'betty')
        assert instance.valid?
        assert instance.errors.empty?
      end
    end

  end
end
