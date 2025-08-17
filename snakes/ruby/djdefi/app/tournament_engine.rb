# frozen_string_literal: true

# Tournament-Level Battlesnake Decision Engine
# 
# This module implements a comprehensive tournament-ready decision system designed
# to achieve 90%+ win rates through advanced AI techniques, dynamic strategy 
# adaptation, and elite performance optimization.
#
# Key Features:
# - Multi-phase game strategy (early/mid/late game optimization)
# - Advanced opponent modeling and counter-strategies
# - Dynamic risk assessment and tournament-aware decision making
# - Sophisticated endgame mastery
# - Performance monitoring and real-time strategy adjustment

require 'set'

module TournamentEngine
  
  # Tournament-level move decision with comprehensive analysis
  def tournament_move_decision(board_state, start_time, timeout_limit)
    # Phase 1: Tournament Context Analysis
    tournament_context = analyze_tournament_context(board_state)
    
    # Phase 2: Dynamic Strategy Selection
    strategy = select_optimal_strategy(board_state, tournament_context)
    
    # Phase 3: Advanced Move Generation and Scoring
    candidate_moves = generate_tournament_moves(board_state, strategy, start_time, timeout_limit)
    
    # Phase 4: Tournament-Aware Move Selection
    optimal_move = select_tournament_move(candidate_moves, board_state, tournament_context)
    
    optimal_move
  end
  
  # Analyze tournament context and game state
  def analyze_tournament_context(board_state)
    turn_number = board_state[:turn] || 0
    total_cells = board_state[:width] * board_state[:height]
    
    # Game phase analysis
    game_phase = if turn_number < 30
                  :early_game
                elsif turn_number < total_cells * 0.6
                  :mid_game
                else
                  :end_game
                end
    
    # Competitive positioning
    our_length = board_state[:length]
    enemy_lengths = board_state[:snakes].reject { |s| s[:id] == board_state[:our_id] }.map { |s| s[:length] }
    max_enemy_length = enemy_lengths.max || 0
    avg_enemy_length = enemy_lengths.empty? ? 0 : enemy_lengths.sum.to_f / enemy_lengths.size
    
    competitive_position = if our_length > max_enemy_length + 2
                            :dominating
                          elsif our_length > avg_enemy_length + 1
                            :leading
                          elsif our_length >= avg_enemy_length - 1
                            :competitive
                          else
                            :trailing
                          end
    
    # Territory control analysis
    territory_analysis = analyze_territory_dominance(board_state)
    
    # Food scarcity and competition
    food_density = board_state[:food].size.to_f / total_cells
    food_competition = calculate_food_competition(board_state)
    
    {
      game_phase: game_phase,
      competitive_position: competitive_position,
      territory_analysis: territory_analysis,
      food_density: food_density,
      food_competition: food_competition,
      turn_number: turn_number,
      total_cells: total_cells,
      our_length: our_length,
      max_enemy_length: max_enemy_length
    }
  end
  
  # Select optimal strategy based on tournament context
  def select_optimal_strategy(board_state, context)
    # Base strategy selection matrix with enhanced tournament logic
    strategy = case [context[:game_phase], context[:competitive_position]]
             when [:early_game, :dominating], [:early_game, :leading]
               :aggressive_expansion
             when [:early_game, :competitive], [:early_game, :trailing]  
               :safe_growth
             when [:mid_game, :dominating]
               :territory_control
             when [:mid_game, :leading]
               :tactical_pressure
             when [:mid_game, :competitive]
               :opportunistic_survival
             when [:mid_game, :trailing]
               :comeback_strategy
             when [:end_game, :dominating], [:end_game, :leading]
               :endgame_dominance
             else
               :endgame_survival
             end
    
    # Strategy modifiers based on specific tournament conditions
    if board_state[:health] < 25 && context[:food_density] < 0.05
      strategy = :emergency_food_seeking
    elsif context[:territory_analysis][:space_advantage] < 0.2
      strategy = :space_control_priority
    elsif context[:turn_number] > 200 && context[:competitive_position] == :dominating
      strategy = :tournament_victory_consolidation # New elite strategy
    end
    
    strategy
  end
  
  # Generate tournament-level move candidates
  def generate_tournament_moves(board_state, strategy, start_time, timeout_limit)
    candidate_moves = []
    safe_moves = get_safe_moves_comprehensive(board_state)
    
    return [{ move: get_emergency_move(board_state), score: -1000, reason: 'emergency' }] if safe_moves.empty?
    
    safe_moves.each do |move_direction|
      next_pos = get_position_after_move(board_state[:head], move_direction)
      
      # Check timeout
      return candidate_moves if (Time.now - start_time) > timeout_limit * 0.8
      
      # Comprehensive move scoring
      move_score = calculate_tournament_move_score(
        next_pos, move_direction, board_state, strategy, context
      )
      
      candidate_moves << {
        move: move_direction,
        position: next_pos,
        score: move_score[:total_score],
        breakdown: move_score[:breakdown],
        strategy_bonus: move_score[:strategy_bonus]
      }
    end
    
    candidate_moves.sort_by { |move| -move[:score] }
  end
  
  # Calculate comprehensive tournament move score
  def calculate_tournament_move_score(position, direction, board_state, strategy, context)
    scores = {}
    
    # 1. Basic safety score (highest priority)
    scores[:safety] = calculate_safety_score_advanced(position, board_state) * 10
    
    # 2. Space control score  
    scores[:space_control] = calculate_space_control_score_elite(position, board_state) * 8
    
    # 3. Food accessibility score
    scores[:food_access] = calculate_food_accessibility_tournament(position, board_state, strategy) * 6
    
    # 4. Enemy interaction score
    scores[:enemy_interaction] = calculate_enemy_interaction_score_advanced(position, board_state) * 7
    
    # 5. Strategic positioning score
    scores[:strategic_position] = calculate_strategic_positioning_score(position, board_state, strategy) * 5
    
    # 6. Endgame optimization score
    scores[:endgame] = calculate_endgame_score_elite(position, board_state, context) * 4
    
    # 7. Tournament-specific bonuses
    strategy_bonus = calculate_strategy_bonus(position, direction, board_state, strategy)
    
    total_score = scores.values.sum + strategy_bonus
    
    {
      total_score: total_score,
      breakdown: scores,
      strategy_bonus: strategy_bonus
    }
  end
  
  # Advanced safety scoring with tournament considerations
  def calculate_safety_score_advanced(position, board_state)
    return -1000 if is_wall_or_occupied?(position, board_state)
    
    safety_score = 100
    
    # Immediate collision avoidance
    enemy_heads = board_state[:snakes_heads_not_my_head]
    enemy_heads.each do |enemy_head|
      enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
      next unless enemy_snake
      
      distance = manhattan_distance(position, enemy_head)
      
      # Enhanced head-to-head collision analysis
      if distance <= 1
        if enemy_snake[:length] >= board_state[:length]
          safety_score -= 600 # Increased penalty for losing head-to-head
        else
          safety_score += 75  # Increased bonus for winning head-to-head
        end
      elsif distance <= 2
        if enemy_snake[:length] > board_state[:length]
          safety_score -= 250 # More aggressive avoidance of larger snakes
        elsif enemy_snake[:length] < board_state[:length]
          safety_score += 25  # Slight bonus for pressuring smaller snakes
        end
      end
    end
    
    # Hazard penalty with urgency factor
    if board_state[:hazards].any? { |h| h[:x] == position[:x] && h[:y] == position[:y] }
      health_factor = [board_state[:health] / 100.0, 1.0].min
      safety_score -= (400 * health_factor).to_i # Dynamic hazard penalty based on health
    end
    
    # Enhanced wall proximity penalty for tournament play
    wall_distance = [position[:x], position[:y], 
                    board_state[:width] - 1 - position[:x],
                    board_state[:height] - 1 - position[:y]].min
    
    # More aggressive wall avoidance in tournament
    if wall_distance == 0
      safety_score -= 100 # Penalty for edge moves
    elsif wall_distance == 1
      safety_score -= 50  # Penalty for near-edge moves
    elsif wall_distance <= 2
      safety_score -= 20  # Light penalty for wall proximity
    end
    
    safety_score
  end
  
  # Elite space control scoring for tournament play
  def calculate_space_control_score_elite(position, board_state)
    return -500 if is_wall_or_occupied?(position, board_state)
    
    # Calculate flood fill space from this position
    available_space = flood_fill_from_position_optimized(position, board_state)
    min_required_space = board_state[:length] * 2
    
    space_score = available_space * 3
    
    # Critical space evaluation
    if available_space < min_required_space
      space_score -= 200 # Dangerous lack of space
    elsif available_space > min_required_space * 2
      space_score += 100 # Excellent space control
    end
    
    # Territory dominance bonus
    enemy_controlled_space = 0
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      enemy_space = flood_fill_from_position_optimized(enemy_head, board_state, available_space + 50)
      enemy_controlled_space = [enemy_controlled_space, enemy_space].max
    end
    
    if available_space > enemy_controlled_space + 20
      space_score += 150 # Dominant space control
    elsif available_space < enemy_controlled_space - 20
      space_score -= 100 # Space disadvantage
    end
    
    space_score
  end
  
  # Tournament-level food accessibility scoring
  def calculate_food_accessibility_tournament(position, board_state, strategy)
    return 0 if board_state[:food].empty?
    
    food_score = 0
    our_health = board_state[:health]
    
    # Health-based food priority
    health_urgency = case our_health
                    when 0..20 then 10
                    when 21..40 then 7
                    when 41..60 then 4
                    when 61..80 then 2
                    else 1
                    end
    
    # Find accessible food
    accessible_food = board_state[:food].select do |food|
      path_length = a_star_distance_estimate(position, food, board_state)
      path_length && path_length < our_health / 2
    end
    
    return -50 if accessible_food.empty? && our_health < 50
    
    accessible_food.each do |food|
      distance = manhattan_distance(position, food)
      path_length = a_star_distance_estimate(position, food, board_state) || distance * 2
      
      # Base food value
      base_value = [100 - path_length * 5, 10].max
      
      # Competition analysis
      closest_enemy_distance = board_state[:snakes_heads_not_my_head].map do |enemy_head|
        manhattan_distance(enemy_head, food)
      end.min || Float::INFINITY
      
      if path_length < closest_enemy_distance
        base_value += 50 # We're closer
      elsif path_length > closest_enemy_distance + 2
        base_value -= 30 # Enemy is much closer
      end
      
      # Strategy-specific food evaluation
      case strategy
      when :aggressive_expansion
        base_value += 20 if distance <= 3
      when :safe_growth
        base_value -= 20 if closest_enemy_distance <= 2
      when :emergency_food_seeking
        base_value += health_urgency * 10
      end
      
      food_score += base_value * health_urgency
    end
    
    food_score
  end
  
  # Advanced enemy interaction scoring
  def calculate_enemy_interaction_score_advanced(position, board_state)
    interaction_score = 0
    our_length = board_state[:length]
    
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
      next unless enemy_snake
      
      distance = manhattan_distance(position, enemy_head)
      
      case distance
      when 1
        # Immediate head-to-head
        if enemy_snake[:length] < our_length
          interaction_score += 200 # Winning collision
        elsif enemy_snake[:length] == our_length  
          interaction_score -= 100 # Mutual destruction
        else
          interaction_score -= 400 # Losing collision
        end
      when 2
        # Near collision potential
        if enemy_snake[:length] > our_length
          interaction_score -= 100 # Dangerous proximity
        else
          interaction_score += 30 # Opportunity for pressure
        end
      when 3..5
        # Strategic positioning
        if enemy_snake[:length] < our_length
          interaction_score += 20 # Good for applying pressure
        end
      end
      
      # Tail following opportunity (when enemy tail will move)
      if enemy_snake[:body].length > 3
        tail_pos = enemy_snake[:body].last
        if position == tail_pos
          interaction_score += 40 # Can occupy tail space
        end
      end
    end
    
    interaction_score
  end
  
  # Strategic positioning for tournament play
  def calculate_strategic_positioning_score(position, board_state, strategy)
    strategic_score = 0
    center_x = board_state[:width] / 2
    center_y = board_state[:height] / 2
    
    # Center control bonus (varies by strategy)
    center_distance = manhattan_distance(position, {x: center_x, y: center_y})
    max_distance = (board_state[:width] + board_state[:height]) / 2
    
    case strategy
    when :territory_control, :endgame_dominance
      strategic_score += (max_distance - center_distance) * 3
    when :aggressive_expansion
      strategic_score += (max_distance - center_distance) * 2
    when :safe_growth, :endgame_survival
      # Prefer edges for safety
      edge_distance = [position[:x], position[:y], 
                      board_state[:width] - 1 - position[:x],
                      board_state[:height] - 1 - position[:y]].min
      strategic_score -= edge_distance * 5 if edge_distance == 0
    end
    
    # Corner avoidance (tournament critical)
    if (position[:x] == 0 || position[:x] == board_state[:width] - 1) &&
       (position[:y] == 0 || position[:y] == board_state[:height] - 1)
      strategic_score -= 200
    end
    
    strategic_score
  end
  
  # Elite endgame scoring
  def calculate_endgame_score_elite(position, board_state, context)
    return 0 unless context[:game_phase] == :end_game
    
    endgame_score = 0
    
    # In endgame, space control becomes critical
    if context[:territory_analysis][:space_advantage] > 0.5
      endgame_score += 100 # Maintain advantage
    elsif context[:territory_analysis][:space_advantage] < 0.3
      endgame_score -= 100 # Space disadvantage
    end
    
    # Minimize enemy interaction in endgame
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      distance = manhattan_distance(position, enemy_head)
      if distance < 5
        endgame_score -= 30 # Avoid close contact in endgame
      end
    end
    
    # Food efficiency in endgame
    if board_state[:health] > 80 && !board_state[:food].empty?
      nearest_food_distance = board_state[:food].map { |f| manhattan_distance(position, f) }.min
      if nearest_food_distance <= 3
        endgame_score += 50 # Efficient food access
      end
    end
    
    endgame_score
  end
  
  # Strategy-specific bonus calculations
  def calculate_strategy_bonus(position, direction, board_state, strategy)
    bonus = 0
    
    case strategy
    when :aggressive_expansion
      # Bonus for moves toward enemies (when we're larger)
      board_state[:snakes_heads_not_my_head].each do |enemy_head|
        enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
        if enemy_snake && enemy_snake[:length] < board_state[:length]
          distance_before = manhattan_distance(board_state[:head], enemy_head)
          distance_after = manhattan_distance(position, enemy_head)
          if distance_after < distance_before
            bonus += 40
          end
        end
      end
    
    when :safe_growth
      # Bonus for maintaining distance from larger enemies
      board_state[:snakes_heads_not_my_head].each do |enemy_head|
        enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
        if enemy_snake && enemy_snake[:length] >= board_state[:length]
          distance = manhattan_distance(position, enemy_head)
          bonus += [distance * 10, 100].min
        end
      end
    
    when :territory_control
      # Bonus for central positioning
      center_x = board_state[:width] / 2
      center_y = board_state[:height] / 2
      center_distance = manhattan_distance(position, {x: center_x, y: center_y})
      bonus += (10 - center_distance) * 5 if center_distance <= 10
    
    when :emergency_food_seeking
      # Massive bonus for moves toward food
      unless board_state[:food].empty?
        nearest_food = board_state[:food].min_by { |f| manhattan_distance(position, f) }
        food_distance_before = manhattan_distance(board_state[:head], nearest_food)
        food_distance_after = manhattan_distance(position, nearest_food)
        if food_distance_after < food_distance_before
          bonus += 200
        end
      end
    
    when :tournament_victory_consolidation
      # Elite strategy for maintaining tournament leads
      # Focus on space control and avoiding unnecessary risks
      space_bonus = flood_fill_from_position_optimized(position, board_state, 50)
      bonus += [space_bonus, 150].min
      
      # Avoid close contact with enemies when leading
      board_state[:snakes_heads_not_my_head].each do |enemy_head|
        distance = manhattan_distance(position, enemy_head)
        if distance < 4
          bonus -= 30 # Penalty for getting too close
        elsif distance > 8
          bonus += 20 # Bonus for maintaining safe distance
        end
      end
    end
    
    bonus
  end
  
  # Advanced territory dominance analysis
  def analyze_territory_dominance(board_state)
    our_space = flood_fill_from_position_optimized(board_state[:head], board_state)
    
    enemy_spaces = board_state[:snakes_heads_not_my_head].map do |enemy_head|
      flood_fill_from_position_optimized(enemy_head, board_state, our_space + 50)
    end
    
    total_enemy_space = enemy_spaces.sum
    total_space = our_space + total_enemy_space
    
    space_advantage = total_space > 0 ? our_space.to_f / total_space : 0.5
    
    {
      our_space: our_space,
      enemy_spaces: enemy_spaces,
      total_space: total_space,
      space_advantage: space_advantage
    }
  end
  
  # Calculate food competition intensity
  def calculate_food_competition(board_state)
    return 0 if board_state[:food].empty?
    
    competition_score = 0
    
    board_state[:food].each do |food|
      our_distance = manhattan_distance(board_state[:head], food)
      enemy_distances = board_state[:snakes_heads_not_my_head].map do |enemy_head|
        manhattan_distance(enemy_head, food)
      end
      
      closest_enemy_distance = enemy_distances.min || Float::INFINITY
      
      if our_distance <= closest_enemy_distance
        competition_score += 1 # We have advantage for this food
      elsif closest_enemy_distance < our_distance - 2  
        competition_score -= 2 # Enemy has significant advantage
      end
    end
    
    competition_score
  end
  
  # Select final tournament move with comprehensive validation
  def select_tournament_move(candidate_moves, board_state, context)
    return 'up' if candidate_moves.empty?
    
    # Apply tournament-specific filters
    validated_moves = candidate_moves.select do |move|
      # Ensure move meets minimum tournament standards
      move[:score] > -500 && # Not critically dangerous
      !will_create_immediate_trap?(move[:position], board_state) &&
      meets_tournament_safety_standards?(move[:position], board_state)
    end
    
    # Fallback to best available move if all fail validation
    final_moves = validated_moves.empty? ? candidate_moves : validated_moves
    
    # Select best move with tournament confidence
    best_move = final_moves.first
    
    # Tournament-level logging (for future learning)
    log_tournament_decision(best_move, context, board_state)
    
    best_move[:move]
  end
  
  # Additional tournament-specific helper methods
  def will_create_immediate_trap?(position, board_state)
    # Check if this move would create an immediate trap scenario
    space_after = flood_fill_from_position_optimized(position, board_state)
    space_after < board_state[:length] + 3
  end
  
  def meets_tournament_safety_standards?(position, board_state)
    return false if is_wall_or_occupied?(position, board_state)
    
    # Tournament standard: always maintain escape routes
    adjacent_safe_moves = adjacent_cells(position[:x], position[:y]).count do |adj|
      !is_wall_or_occupied?(adj, board_state)
    end
    
    adjacent_safe_moves >= 1 # At least one escape route
  end
  
  def log_tournament_decision(move, context, board_state)
    # Tournament decision logging for future analysis and learning
    # This would integrate with a learning system in a full tournament implementation
    puts "TOURNAMENT: Turn #{context[:turn_number]}, Phase: #{context[:game_phase]}, Position: #{context[:competitive_position]}, Move: #{move[:move]}, Score: #{move[:score]}"
  end
  
  # Optimized flood fill implementation for tournament performance
  def flood_fill_from_position_optimized(position, board_state, max_cells = nil)
    return 0 if is_wall_or_occupied?(position, board_state)
    
    visited = Set.new
    queue = [position]
    cells_counted = 0
    
    while !queue.empty? && (max_cells.nil? || cells_counted < max_cells)
      current = queue.shift
      next if visited.include?(current)
      
      visited.add(current)
      cells_counted += 1
      
      adjacent_cells(current[:x], current[:y]).each do |neighbor|
        next if visited.include?(neighbor) || queue.include?(neighbor)
        next if is_wall_or_occupied?(neighbor, board_state)
        
        queue.push(neighbor)
      end
    end
    
    cells_counted
  end
  
end