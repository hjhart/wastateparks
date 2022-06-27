# frozen_string_literal: true

require_relative '../../src/application'
require 'rspec'

class TestClass
  include Storage
end

RSpec.describe Storage do
  describe 'storing data' do
    it 'can read after it has written' do
      subject = TestClass.new
      subject.storage.write('butts', 'Test')
      result = subject.storage.read.first
      expect(result.guid).to eq('butts')
      expect(result.message).to eq('Test')
      expect(result.id).to_not be_nil
      expect(result.created_at).to_not be_nil
      subject.storage.cleanup
    end
  end
end
