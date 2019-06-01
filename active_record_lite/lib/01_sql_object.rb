require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT 
        *
      FROM 
        "#{self.table_name}"
    SQL

    columns.first.map! { |column| column.to_sym }
    @columns = columns.first
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=") do |value|
        attributes[column] = value
      end

      define_method(column) do 
        attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    name = self.to_s
    "#{name[0].downcase}#{name[1..-1]}s"
  end

  def self.all
    table = DBConnection.execute(<<-SQL)
      SELECT
        "#{self.table_name}".*
      FROM
        "#{self.table_name}"
    SQL

    parse_all(table)
  end

  def self.parse_all(results)
    instances = []
    results.each do |result|
      instances << self.new(result)
    end
    instances
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT 
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL

    parse_all(result).first
  end

  def initialize(params = {})
    params.each do |k, v|
      attribute = k.to_sym
      if self.class.columns.include?(attribute)
        self.send("#{attribute}=", v)
      else
        raise "unknown attribute '#{attribute}'"
      end
    end
  end

  def attributes
    @attributes ||= Hash.new {Hash.new}
  end

  def attribute_values
    
  end

  def insert
    col_names = columns.join(",")
    question_marks = ["?"] * columns.length

    
  end

  def update
    # ...
  end

  def save
    # ...
  end

end
