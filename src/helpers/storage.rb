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
  include Logging

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
      create table if not exists notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        guid varchar(255) not null,
        notified_at timestamp not null
      );

    SQL
    storage.execute <<-SQL
      create table if not exists availability (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        guid varchar(255) not null,
        message varchar(255),
        url varchar(255),
        data varchar(1024),
        created_at timestamp not null 
      );
    SQL
  end

  def cleanup
    storage.execute <<-SQL
      drop table if exists availability;
    SQL
    storage.execute <<-SQL
      drop table if exists notifications;
    SQL
  end

  def insert_availability(guid:, message:, data:, url:)
    storage.execute <<-SQL
      INSERT INTO availability (guid, message, data, url, created_at) VALUES ('#{guid}', '#{message}', '#{data.to_json}', '#{url}', datetime('now'))
    SQL
  end

  def all_availability
    results = storage.execute <<-SQL
      select * from availability;
    SQL
    results.map { |row| Result.new(*row) }
  end

  def already_sent_notification_for_guid?(guid)
    result = storage.execute <<-SQL
      select * from notifications where guid = '#{guid}';
    SQL
    !result.empty?
  end

  def mark_guid_as_sent(guid)
    storage.execute <<-SQL
      insert into notifications (guid, notified_at) values ('#{guid}', datetime('now'));
    SQL
  end
end
