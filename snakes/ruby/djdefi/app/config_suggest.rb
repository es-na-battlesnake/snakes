require 'json'
require 'yaml'
require 'rumale'

def suggest
    # Load model_data.json
    file = File.read('model_data.json')
    model_data_raw = JSON.parse(file)

    # Load config.yml
    config_file = File.read('config.yml')
    config = YAML.load(config_file)

    # Extract features and config settings from model data
    features = []
    turns = model_data_raw.map { |game| game['turn'] }

    model_data_raw.each do |game|
    features << [
        game['your_health'],
        game['snakes'].map { |snake| snake['health'] }.sum,
        game['snakes'].map { |snake| snake['length'] }.sum,
        game['snakes'].map { |snake| snake['latency'].to_i }.sum,
        # Turns survived
        game['turn']
    ]
    end

    # Convert the data to Numo::NArray
    x = Numo::NArray[*features]
    y = Numo::NArray[*turns]

    puts "x shape: #{x.shape}"
    puts "y shape: #{y.shape}"

    # Train a linear regression model using the features and config settings
    lr = Rumale::LinearModel::LinearRegression.new
    lr.fit(x, y)

    # Evaluate the trained model and suggest improvements to the configuration settings
    # We will use R^2 (coefficient of determination) to measure the performance of the model
    r2 = lr.score(x, y)
    puts "R^2: #{r2}"

    # If R^2 is low, it means that the model can be improved
    if r2 < 0.7
    # Suggest improvements by adjusting the config settings based on the regression coefficients
    improved_config = config.clone
    lr.instance_variable_get(:@weight_vec).each_with_index do |coeff, index|
        key1, key2 = improved_config.keys[index / 2], improved_config.values[index % 2].keys[0]
        improved_config[key1][key2] += coeff.round
    end

    # If the number of turns is not increasing, we will suggest educated random guesses for new values
    if improved_config['turns'] <= config['turns']
        improved_config['turns'] += rand(1..10)
        improved_config['food'] += rand(1..10)
        improved_config['snakes'] += rand(1..10)
        improved_config['health'] += rand(1..10)
    end

    # Return the improved config
    improved_config
    else
    # If R^2 is high, it means that the model is good enough and we will return the original config
    config
    end

end

suggest
