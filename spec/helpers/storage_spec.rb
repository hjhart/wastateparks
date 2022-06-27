# frozen_string_literal: true

require_relative '../../src/application'
require 'rspec'

class TestClass
  include Storage
end

RSpec.describe Storage do
  let(:subject) { TestClass.new }
  
  before do
    subject.storage.setup
  end

  after do 
    subject.storage.cleanup
  end

  describe 'storing notifications' do
    it 'can mark a guid as sent' do
      expect(subject.storage.already_sent_notification_for_guid?('234')).to be_falsey
      subject.storage.mark_guid_as_sent('234') 
      expect(subject.storage.already_sent_notification_for_guid?('234')).to be_truthy
    end
  end

  describe 'storing records' do
    it 'can read after it has written' do
      subject.storage.insert_availability(guid: '12345', message: 'Test', data: { foo: "Baz" }, url: "https://www.whitehouse.com")
      result = subject.storage.all_availability.first
      expect(result.guid).to eq('12345')
      expect(result.message).to eq("Test")
      expect(result.data).to eq({ 'foo' => "Baz" })
      expect(result.url).to eq("https://www.whitehouse.com")
      expect(result.id).to_not be_nil
      expect(result.created_at).to_not be_nil
    end
  end
end
