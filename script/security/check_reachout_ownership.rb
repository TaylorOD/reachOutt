require "minitest/autorun"

# Loads the production controller into a minimal Rails-free test harness.
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

load File.expand_path("../../app/controllers/api/reachouts_controller.rb", __dir__)

class ReachoutOwnershipTest < Minitest::Test
  class OwnedCollection
    def initialize(records)
      @records = records
    end

    def find_by(id:)
      @records.find { |record| record.id.to_s == id.to_s }
    end
  end

  class Record
    attr_reader :id, :destroyed
    def initialize(id)
      @id = id
      @destroyed = false
    end

    def destroy
      @destroyed = true
    end
  end

  User = Struct.new(:reachouts, :contacts)

  def controller(reachouts: [], contacts: [], params: {})
    c = Api::ReachoutsController.new
    c.user = User.new(OwnedCollection.new(reachouts), OwnedCollection.new(contacts))
    c.params = params
    c
  end

  def assert_not_found(result, expected)
    assert_equal({ error: expected }, result.fetch(:options).fetch(:json))
    assert_equal :not_found, result.fetch(:options).fetch(:status)
  end

  def test_owner_can_view_own_reachout
    c = controller(reachouts: [Record.new(1)], params: { id: "1" })
    c.show
    assert_equal :show, c.rendered.fetch(:view)
  end

  def test_cannot_read_other_users_reachout
    c = controller(reachouts: [Record.new(1)], params: { id: "2" })
    c.show
    assert_not_found(c.rendered, "Reachout not found")
  end

  def test_owner_can_delete_own_reachout
    owned = Record.new(1)
    c = controller(reachouts: [owned], params: { id: "1" })
    c.destroy
    assert owned.destroyed
  end

  def test_cannot_delete_other_users_reachout
    other = Record.new(2)
    c = controller(reachouts: [Record.new(1)], params: { id: "2" })
    c.destroy
    assert_not_found(c.rendered, "Reachout not found")
    refute other.destroyed
  end

  def test_unknown_reachout_cannot_be_updated
    c = controller(reachouts: [], params: { id: "2", frequency: "1d" })
    c.update
    assert_not_found(c.rendered, "Reachout not found")
  end

  def test_cannot_assign_unowned_contact_when_updating
    owned = Record.new(1)
    other_contact = Record.new(99)
    c = controller(reachouts: [owned], contacts: [Record.new(10)], params: { id: "1", contact_id: other_contact.id })
    c.update
    assert_not_found(c.rendered, "Contact not found")
  end

  def test_cannot_create_reachout_for_unowned_contact
    c = controller(contacts: [Record.new(10)], params: { contact_id: "99" })
    c.create
    assert_not_found(c.rendered, "Contact not found")
  end

  def test_authentication_and_scoping_remain_enforced
    source = File.read(File.expand_path("../../app/controllers/api/reachouts_controller.rb", __dir__))
    assert_includes source, "before_action :authenticate_user"
    refute_match(/\bReachout\.find_by\b/, source)
    assert_includes source, "current_user.reachouts.find_by"
    assert_includes source, "current_user.contacts.find_by"
  end
end
