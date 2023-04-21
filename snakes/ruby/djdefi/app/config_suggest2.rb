require 'json'
require 'yaml'

# Load the model_data.json file 
model_data = File.readlines('model_data.json').map { |line| JSON.parse(line) }

# Set the number of generations to run
generations = 50

# Set the number of individuals in each generation
population_size = 5

# Set the number of individuals to keep in each generation
elite_size = 2

# Set the number of individuals to mutate in each generation
mutation_size = 2

# Set the number of individuals to crossover in each generation
crossover_size = 2

# Set the number of individuals to randomly generate in each generation
random_size = 1

# Output the number of combinations we will be testing
puts "Testing #{population_size * generations} combinations..."

# Start analyzing the model_data.json file
puts "Analyzing model_data.json file..."

# Create a method to generate a random configuration
def random_config(model_data)
  config = {}
  model_data[0]['config'].each do |k, v|
    config[k] = {}
    config[k]['wrapped'] = rand(v['wrapped'] * -10)
    config[k]['standard'] = rand(v['standard'] * -10)
  end
  return config
end

# Create a method to calculate the turn number for a given configuration
def calculate_turn(config, model_data)
  # Write the configuration to config.yml file before running the game
  File.open('config.yml', 'w') do |f|
    f.write(config.to_yaml)
  end

  # Run the game with the given configuration and capture the output. Redirect stderr to stdout so we can capture it. We only care about the turn number, so we can filter out the rest of the output.
  output = `/root/go/bin/battlesnake play -W 11 -H 11 --name ruby-danger-noodle --url http://code-snek:4567/ 2>&1 | grep completed | awk '{print $6}'`
  
  # Extract the turn number from the output
  turn = output[/\d+/].to_i
  
  puts "Turn: #{turn}"
  return turn
end

# Create a method to generate a new generation of configurations
def generate_generation(model_data, population_size, elite_size, mutation_size, crossover_size, random_size, current_generation)
  # Sort the current generation by turn number (highest to lowest)
  sorted_generation = current_generation.sort_by { |config| calculate_turn(config, model_data) }.reverse

  # Select the elite configurations to keep
  elite = sorted_generation[0..elite_size-1]

  # Generate the mutation configurations
    mutation = []
    mutation_size.times do
    parent = elite.sample
    child = Marshal.load(Marshal.dump(parent))
    key = model_data[0]['config'].keys.sample
    if child[key].nil?
        # Handle case where child does not have a config key
        child[key] = {
        'wrapped' => rand(model_data[0]['config'][key]['wrapped'] * -1),
        'standard' => rand(model_data[0]['config'][key]['standard'] * -1)
        }
    else
        # Use config values from parent
        child[key]['wrapped'] = parent[key]['wrapped']
        child[key]['standard'] = parent[key]['standard']
    end
    mutation << child
    end


  # Generate the crossover configurations
    crossover = []
    crossover_size.times do
    parent1 = elite.sample
    parent2 = elite.sample
    child = Marshal.load(Marshal.dump(parent1))
    key = model_data[0]['config'].keys.sample
    if parent1[key].nil? || parent2[key].nil?
        # Handle case where parent(s) do not have a config key
        child[key] = {
        'wrapped' => rand(model_data[0]['config'][key]['wrapped'] * -1),
        'standard' => rand(model_data[0]['config'][key]['standard'] * -1)
        }
    else
        # Use config values from parents
        child[key] = {
        'wrapped' => (parent1[key]['wrapped'] + parent2[key]['wrapped']) / 2,
        'standard' => (parent1[key]['standard'] + parent2[key]['standard']) / 2
        }
    end
    crossover << child
    end

    # Generate the random configurations
    random = []
    random_size.times do
      random << random_config(model_data)
    end
  
    # Combine all of the configurations into the new generation
    new_generation = elite + mutation + crossover + random
  
    return new_generation
  end
  
    # Generate the initial generation
    initial_historical_configs = model_data.map { |data| data }
    puts "Number of historical configs: #{initial_historical_configs.size}"

    sorted_historical_configs = initial_historical_configs.sort_by { |config| config['turn'] }.reverse
    puts "Highest turn value recorded in model_data.json: #{sorted_historical_configs.first['turn']}"

    best_historical_configs = sorted_historical_configs.first(5)
    # Puts the best historical turn values to the console
    best_historical_configs.each do |config|
        puts "Best historical turn value: #{config['turn']}"
        end
    num_random_configs = population_size - best_historical_configs.size
    num_random_configs = 0 if num_random_configs < 0

    current_generation = best_historical_configs
    num_random_configs.times do
    current_generation << random_config(model_data)
    end


  
  # Run the genetic algorithm
  generations.times do |i|
    puts "Running generation #{i+1}..."
    current_generation = generate_generation(model_data, population_size, elite_size, mutation_size, crossover_size, random_size, current_generation)
  end
  
  # Sort the final generation by turn number (highest to lowest)
  sorted_generation = current_generation.sort_by { |config| calculate_turn(config, model_data) }.reverse
  
  # Output the highest turn value recorded in the model_data.json file to the console
    puts "Highest turn value recorded in model_data.json: #{sorted_historical_configs[0]['turn']}"

  # Output the top configuration from sorted_historical_configs to config.yml
    File.open('config.yml', 'w') do |f|
    f.write(sorted_historical_configs[0].to_yaml)
    end

   
  