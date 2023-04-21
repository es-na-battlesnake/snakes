require 'darwinning'
require 'json'
require 'yaml'

class ConfigGenes
  include Darwinning

  GENE_RANGES = YAML.load(File.read('config.yml'))

  GENE_RANGES.each do |key1, sub_hash|
    sub_hash.each do |key2, value|
      gene "#{key1}_#{key2}", value: (-100..100)
    end
  end
end

class ConfigEvolver < Darwinning::Evolver
  attr_accessor :model_data_raw

  def fitness_function(member)
    # Extract the configuration values from the member's genes
    config = {}
    member.genes.each do |gene|
        key = gene.name.split("_").map(&:capitalize).join(" ")
        config[key] = gene.value
    end

    # Find the model data that matches the configuration
    matching_data = model_data_raw.select do |data|
        data['config'] == config
    end

    # Calculate the fitness as the average number of turns survived
    if matching_data.empty?
        fitness = 0
    else
        fitness = matching_data.map { |data| data['turns_survived'] }.reduce(:+) / matching_data.size.to_f
    end

    # Return the fitness value
    fitness
end

# Load model_data.json
model_data_raw = []
File.foreach('model_data.json') do |line|
  begin
    parsed_line = JSON.parse(line.strip)
    model_data_raw << parsed_line
  rescue JSON::ParserError => e
    puts "Error parsing line: #{e.message}"
  end
end

evolver = ConfigEvolver.new(
  population: Darwinning::Population.new(
    organism: ConfigGenes,
    size: 10,
    generations: 20
  )
)
evolver.model_data_raw = model_data_raw
evolver.evolve!

# Access the best member
best_member = evolver.population.best_member

# Extract the best config values
best_config = {}
best_member.genes.each do |gene|
  key1, key2 = gene.name.split('_')
  best_config[key1] ||= {}
  best_config[key1][key2] = gene.value
end

puts "Best Config: #{best_config.inspect}"
