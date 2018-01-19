require 'test_helper'

class KeyringTest < ActiveSupport::TestCase

  test 'create initial key' do
    keyring.create 'type', 'value'
    assert_equal 'value', keyring.key_of_type('type')['value']
  end

  test 'raise on creating twice' do
    keyring.create 'type', 'value'
    assert_raises Keyring::Error do
      keyring.create 'type', 'value'
    end
  end

  test 'update with new key' do
    keyring.create 'type', 'value'
    initial_rev = keyring.key_of_type('type')['rev']
    keyring.update 'type', rev: initial_rev, value: 'new value'
    assert_equal 'new value', keyring.key_of_type('type')['value']
  end

  test 'raise on updating missing key' do
    assert_raises Keyring::NotFound do
      keyring.update 'type', rev: nil ,value: 'new value'
    end
    assert_nil keyring.key_of_type('type')
  end

  test 'raise on updating without rev' do
    keyring.create 'type', 'value'
    assert_raises Keyring::Error do
      keyring.update 'type', rev: nil ,value: 'new value'
    end
    assert_equal 'value', keyring.key_of_type('type')['value']
  end

  test 'raise on updating with wrong rev' do
    keyring.create 'type', 'value'
    assert_raises Keyring::Error do
      keyring.update 'type', rev: 'wrong rev', value: 'new value'
    end
    assert_equal 'value', keyring.key_of_type('type')['value']
  end

  test 'delete key' do
    keyring.create 'type', 'value'
    initial_rev = keyring.key_of_type('type')['rev']
    keyring.delete 'type', rev: initial_rev
    assert_nil keyring.key_of_type('type')
  end

  test 'raise on deleting missing key' do
    assert_raises Keyring::NotFound do
      keyring.delete 'type', rev: nil
    end
  end

  test 'raise on deleting without rev' do
    keyring.create 'type', 'value'
    assert_raises Keyring::Error do
      keyring.delete 'type', rev: nil
    end
    assert_equal 'value', keyring.key_of_type('type')['value']
  end

  test 'raise on deleting with wrong rev' do
    keyring.create 'type', 'value'
    assert_raises Keyring::Error do
      keyring.delete 'type', rev: 'wrong rev'
    end
    assert_equal 'value', keyring.key_of_type('type')['value']
  end


  protected

  def keyring
    @keyring ||= Keyring.new(teststorage)
  end

  def teststorage
    @teststorage ||= Hash.new.tap do |dummy|
      def dummy.set_key(type, value)
        self[type] = value
      end

      def dummy.keys
        self
      end

      def dummy.delete_key(type)
        self.delete(type)
      end

      def dummy.save; end
    end
  end
end
