module YamlModel
  class Config
    def initialize(name, suffix: nil)
      @name, @suffix = name, suffix
    end

    def read
      return {} unless File.exist?(file)

      YAML.safe_load(File.read(file), [Time])
    end

    def file
      File.join("config", file_name.to_s)
    end

    def file_name
      [@name, @suffix, "yml"].compact.join(".")
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find(id)
      return if id.nil?
      all_hash[id.to_sym]
    end

    def ids
      @ids ||= config[config_name].symbolize_keys.keys.freeze
    end

    def for_ids(*ids)
      ids.flatten.map { |id| find(id) }.compact.freeze
    end

    def all
      all_hash.values
    end

    def config
      @config ||= load_config.freeze
    end

    def load_config
      Config.new(config_name).read
    end

    def config_name
      name.downcase + "s"
    end

    def has_id_based_finders
      ids.each do |id|
        define_singleton_method id do
          find(id)
        end
      end
    end

    def has_predicates
      ids.each do |id|
        define_method "#{id}?" do
          self.id == id
        end
      end
    end

    private

    def all_hash
      @all_hash ||= config[config_name].to_h.map { |id, data|
        id = id.to_sym
        [id, new(**data.to_h.merge(id: id)).freeze]
      }.to_h.freeze
    end
  end

  def to_sym
    id
  end

  def to_param
    id.to_s
  end
end