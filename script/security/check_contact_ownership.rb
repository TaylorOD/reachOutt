require "minitest/autorun"

# Focused, Rails-independent authorization checks against the actual controller.
class ApplicationController
  def self.before_action(*); end

  attr_accessor :params, :user
  attr_reader :rendered

  def current_user
    user
  end

  def render(*args, **options)
    @rendered = { view: args.first, options: options }
  end
end

module Api
end

load File.expand_path("../../app/controllers/api/contacts_controller.rb", __dir__)

class ContactOwnershipTest < Minitest::Test
  class FakeContact
    attr_accessor :first_name, :last_name, :phone_number
    attr_reader :id, :deleted

    def initialize(id)
      @id = id
      @first_name = "Original"
      @last_name = "Person"
      @phone_number = "5550100"
      @deleted = false
    end

    def save
      true
    end

    def destroy
      @deleted = true
    end
  end

  class OwnedContacts
    def initialize(records)
      @records = records
    end

    def find_by(id:)
      @records.find { |record| record.id.to_s == id.to_s }
    end
  end

  User = Struct.new(:contacts)

  def controller(records, id, changes = {})
    c = Api::ContactsController.new
    c.user = User.new(OwnedContacts.new(records))
    c.params = { id: id }.merge(changes)
    c
  end

  def assert_not_found(result)
    assert_equal({ error: "Contact not found" }, result.fetch(:options).fetch(:json))
    assert_equal :not_found, result.fetch(:options).fetch(:status)
  end

  def test_owner_can_view_contact
    c = controller([FakeContact.new(1)], "1")
    c.show
    assert_equal :show, c.rendered.fetch(:view)
  end

  def test_cannot_read_another_users_contact
    c = controller([FakeContact.new(1)], "2")
    c.show
    assert_not_found(c.rendered)
  end

  def test_owner_can_update_contact
    record = FakeContact.new(1)
    c = controller([record], "1", first_name: "Updated")
    c.update
    assert_equal "Updated", record.first_name
    assert_equal :show, c.rendered.fetch(:view)
  end

  def test_cannot_modify_another_users_contact
    other = FakeContact.new(2)
    c = controller([FakeContact.new(1)], "2", first_name: "Stolen")
    c.update
    assert_not_found(c.rendered)
    assert_equal "Original", other.first_name
  end

  def test_owner_can_delete_contact
    owned = FakeContact.new(1)
    c = controller([owned], "1")
    c.destroy
    assert owned.deleted
  end

  def test_cannot_delete_another_users_contact
    other = FakeContact.new(2)
    c = controller([FakeContact.new(1)], "2")
    c.destroy
    assert_not_found(c.rendered)
    refute other.deleted
  end

  def test_existing_authentication_callback_is_preserved
    source = File.read(File.expand_path("../../app/controllers/api/contacts_controller.rb", __dir__))
    assert_includes source, "before_action :authenticate_user"
    refute_match(/Contact\.find_by/, source)
  end
end
