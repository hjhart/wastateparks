# frozen_string_literal: true

module Storage
  # This is the magical bit that gets mixed into your classes
  def storage
    Storage.storage
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.storage
    @storage ||= begin
      storage = SqliteStorage.new
      storage.setup
      storage
    end
  end
end

class SqliteStorage
  require 'sqlite3'

  class Result < Struct.new(:id, :guid, :message, :url, :raw_data, :created_at)
    def data
      @data ||= JSON.parse(raw_data)
    end
  end

  def storage
    @storage ||= SQLite3::Database.new 'test.db'
  end

  def setup
    # Create a table
    storage.execute <<-SQL
      create table if not exists results (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        guid varchar(255),
        message varchar(255),
        url varchar(255),
        data varchar(1024),
        created_at timestamp
      );
    SQL
  end

  def cleanup
    storage.execute <<-SQL
      drop table if exists results;
    SQL
  end

  def insert_availability(guid:, message:, data:, url:)
    storage.execute <<-SQL
    INSERT INTO results (guid, message, data, url, created_at) VALUES ('#{guid}', '#{message}', '#{data.to_json}', '#{url}', datetime('now'))
    SQL
  end

  def read
    results = storage.execute <<-SQL
      select * from results;
    SQL
    results.map { |row| Result.new(*row) }
  end
end
