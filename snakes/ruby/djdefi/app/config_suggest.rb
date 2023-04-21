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
    # Implement your fitness function here
    # The higher the fitness value, the better the member
    # Use member.genes to access the config values and calculate the fitness
    # based on the performance of the model with the given config values
  end
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
