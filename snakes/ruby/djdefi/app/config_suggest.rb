require 'json'
require 'yaml'

# Example model_data.json file:
# {"game_id":"c297d717-9611-48e2-aefc-65095d8cdbac","ruleset":"standard","turn":3,"your_health":98,"snakes":[],"config":{"wall":{"wrapped":0.9435926902943426,"standard":0},"hazard":{"wrapped":339,"standard":1},"hazard_adjacent":{"wrapped":0.348286211576458,"standard":3},"food":{"wrapped":26,"standard":44},"food_hazard":{"wrapped":0.42109876220609666,"standard":1},"food_adjacent":{"wrapped":13,"standard":12},"shared_neighbor":{"wrapped":0.2561653055311247,"standard":0.7262926914415643},"shared_shorter_snake":{"wrapped":27,"standard":3},"shared_longer_snake":{"wrapped":57,"standard":53},"shared_same_length_snake":{"wrapped":19,"standard":8},"empty":{"wrapped":41,"standard":6},"snake_head":{"wrapped":0,"standard":1},"snake_body":{"wrapped":1,"standard":1},"snake_body_neighbor":{"wrapped":9,"standard":5},"corner":{"wrapped":0,"standard":0},"other_snake_head":{"wrapped":0,"standard":0},"other_snake_body":{"wrapped":0,"standard":64},"other_snake_head_neighbor":{"wrapped":0.7263938162903882,"standard":0.21863574799768792},"body":{"wrapped":49,"standard":2},"head":{"wrapped":3,"standard":0},"tail":{"wrapped":0,"standard":1},"my_tail":{"wrapped":0,"standard":11},"my_tail_neighbor":{"wrapped":2,"standard":17},"edge":{"wrapped":0.45866798818329513,"standard":1},"edge_adjacent":{"wrapped":0.6115940388032556,"standard":0},"head_neighbor":{"wrapped":0.8684544249305518,"standard":0.6452868331280207},"three_head_neighbor":{"wrapped":0,"standard":1},"shorter_snake_heads":{"wrapped":0,"standard":2}}}
# {"game_id":"515f118b-37e6-41da-b32c-018b4f8e468e","ruleset":"standard","turn":3,"your_health":98,"snakes":[],"config":{"wall":{"wrapped":0.22997375901515416,"standard":2},"hazard":{"wrapped":290,"standard":11},"hazard_adjacent":{"wrapped":0.1626664390437227,"standard":4},"food":{"wrapped":47,"standard":24},"food_hazard":{"wrapped":0.849837878837693,"standard":0},"food_adjacent":{"wrapped":16,"standard":16},"shared_neighbor":{"wrapped":0.21629949748994703,"standard":0.7707863802475751},"shared_shorter_snake":{"wrapped":9,"standard":2},"shared_longer_snake":{"wrapped":53,"standard":9},"shared_same_length_snake":{"wrapped":14,"standard":2},"empty":{"wrapped":36,"standard":51},"snake_head":{"wrapped":1,"standard":1},"snake_body":{"wrapped":1,"standard":1},"snake_body_neighbor":{"wrapped":6,"standard":7},"corner":{"wrapped":0,"standard":0},"other_snake_head":{"wrapped":1,"standard":1},"other_snake_body":{"wrapped":12,"standard":68},"other_snake_head_neighbor":{"wrapped":0.9167783865192111,"standard":0.9336083920321057},"body":{"wrapped":81,"standard":1},"head":{"wrapped":2,"standard":1},"tail":{"wrapped":1,"standard":0},"my_tail":{"wrapped":13,"standard":20},"my_tail_neighbor":{"wrapped":23,"standard":2},"edge":{"wrapped":0.6503706271638353,"standard":3},"edge_adjacent":{"wrapped":0.15411539435069033,"standard":0},"head_neighbor":{"wrapped":0.9429633867674573,"standard":0.15205183698417857},"three_head_neighbor":{"wrapped":1,"standard":0},"shorter_snake_heads":{"wrapped":1,"standard":2}}}

# Load the model_data.json file 
model_data = File.readlines('model_data.json').map { |line| JSON.parse(line) }

# Use a genetic algorithm to suggest a new config.yml file based on values that result in the highest turn number
# The config.yml file is a simple yaml file that contains the heuristic values controlling the snake's behavior in standard and wrapped modes
# Example:
# ---
# wall:
#   wrapped: 0
#   standard: -5
# hazard:
#   wrapped: -447
#   standard: -15
# ... etc

# Set the number of generations to run
generations = 50

# Set the number of individuals in each generation
population_size = 5

# Set the number of individuals to keep in each generation
elite_size = 3

# Set the number of individuals to mutate in each generation
mutation_size = 2

# Set the number of individuals to crossover in each generation
crossover_size = 1

# Set the number of individuals to randomly generate in each generation
random_size = 3

# Start analyzing the model_data.json file
puts "Analyzing model_data.json file..."

# Create a method to generate a random configuration
def random_config(model_data)
    config = {}
    model_data[0]['config'].each do |k, v|
      config[k] = {}
      config[k]['wrapped'] = rand(v['wrapped'] * -1)
      config[k]['standard'] = rand(v['standard'] * -1)
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
  # Example completion output:
  # INFO 04:09:45.194921 Game completed after 167 turns.
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
    if parent['config'].nil?
      # Handle case where parent does not have a config key
      child[key]['wrapped'] = rand(model_data[0]['config'][key]['wrapped'] * -1)
      child[key]['standard'] = rand(model_data[0]['config'][key]['standard'] * -1)
    else
      # Use config values from parent
      child[key]['wrapped'] = parent['config'][key]['wrapped']
      child[key]['standard'] = parent['config'][key]['standard']
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
    if parent1['config'].nil? || parent2['config'].nil?
      # Handle case where parent(s) do not have a config key
      child[key]['wrapped'] = rand(model_data[0]['config'][key]['wrapped'] * -1)
      child[key]['standard'] = rand(model_data[0]['config'][key]['standard'] * -1)
    else
      # Use config values from parents
      child[key]['wrapped'] = (parent1['config'][key]['wrapped'] + parent2['config'][key]['wrapped']) / 2
      child[key]['standard'] = (parent1['config'][key]['standard'] + parent2['config'][key]['standard']) / 2
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
current_generation = []
population_size.times do
    current_generation << random_config(model_data)
    end

# Run the genetic algorithm
generations.times do |i|
    puts "Running generation #{i+1}..."
    current_generation = generate_generation(model_data, population_size, elite_size, mutation_size, crossover_size, random_size, current_generation)
    end
    
# Sort the final generation by turn number (highest to lowest)
sorted_generation = current_generation.sort_by { |config| calculate_turn(config, model_data) }.reverse
    
# Output number and turn number of the top generation


# Save the best performing generation to a geneology.json file

# Output the top configuration to a config.yml file
File.open('config.yml', 'w') do |f|
    f.write(sorted_generation[0].to_yaml)
    end

