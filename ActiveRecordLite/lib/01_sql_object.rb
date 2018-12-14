require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_accessor :table_name, :columns, :attributes

  def self.columns
    return @columns if @columns
    # @columns ||= DBConnection.execute2(<<-SQL)
    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns = cols[0].map do |column|
      column.to_sym
    end
    
  end

  def self.finalize!
    columns.each do |column| 
      define_method(column) do 
        attributes[column]
      end

      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT 
      *
      FROM
      #{self.table_name}
    SQL

    parse_all(data) 
  end

  def self.parse_all(results)
    
    results.map do |thing|
      self.new(thing)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
      *
      FROM
      #{self.table_name}
      WHERE
      id = ?
    SQL

    return nil if data.empty?
    
    self.new(data.first)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'" 
      end 

      self.send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
