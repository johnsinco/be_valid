require "test_helper"
require 'validators/must_be_validator'


class MustBeValidatorTest < Minitest::Test
  describe "validate_each" do
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



  end
end
