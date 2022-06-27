# frozen_string_literal: true

require_relative '../../src/application'
require 'rspec'

class TestClass
  include Storage
end

RSpec.describe Storage do
  describe 'storing data' do
    let(:subject) { TestClass.new }

    after do 
      subject.storage.cleanup
    end

    it 'can read after it has written' do
      subject.storage.insert_availability(guid: '12345', message: 'Test', data: { foo: "Baz" }, url: "https://www.whitehouse.com")
      result = subject.storage.read.first
      expect(result.guid).to eq('12345')
      expect(result.message).to eq("Test")
      expect(result.data).to eq({ 'foo' => "Baz" })
      expect(result.url).to eq("https://www.whitehouse.com")
      expect(result.id).to_not be_nil
      expect(result.created_at).to_not be_nil
    end
  end
end
