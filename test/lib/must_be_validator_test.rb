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
        instance = clazz.new(name: 0)
        assert instance.valid?
        assert instance.errors.empty?
      end
    end

  end
end
