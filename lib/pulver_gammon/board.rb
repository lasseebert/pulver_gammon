require_relative 'move_combinator'

module PulverGammon
  class Board

    # The board in the form:
    # {black: [checkers], white: [checkers]}
    # Checkers is an array of length 25:
    # Index 0-23: Normal fields where 0-5 is the home board
    # Index 24: Prison
    attr_accessor :fields

    # The next player to move
    attr_accessor :turn

    def initialize(start_turn)
      self.fields = {black: [], white: []}
      checkers = {
        5 => 5,
        7 => 3,
        12 => 5,
        23 => 2
      }
      (0..24).each do |index|
        amount = checkers[index] || 0
        fields[:black] << amount
        fields[:white] << amount
      end

      self.turn = start_turn
    end

    # Moves one dice roll
    # We need to validate the entire roll to take care of situation 
    # where both dice can be used individually but not at the same time
    # A move is a pair: [from_field, amount]
    def move(moves, dice)
      return false unless validate_move(moves, dice)

      turn_fields = fields[turn]
      other_color = turn == :black ? :white : :black
      other_fields = fields[other_color]

      moves.each do |move|
        Board.move_single(move, turn_fields, other_fields)
      end

      self.turn = other_color
      true
    end

    # Returns a boolean indicating if the move is legal
    def validate_move(moves, dice)

      # Must be two dice
      return false unless dice.length == 2

      turn_fields = fields[turn].dup
      other_color = turn == :black ? :white : :black
      other_fields = fields[other_color].dup

      # Check dice
      dice = Array.new(4, dice[0]) if (dice[0] == dice[1])

      if dice.length == moves.length
        # Must match
        dice.sort!
        amounts = moves.map{|x| x[1]}.sort
        (0..dice.length).each do |index|
          return false unless dice[index] == amounts[index]
        end
      else
        # Must not be able to use greater amount
        amount = moves.map{ |move| move[1] }.reduce(:+)
        max_amount = MoveCombinator.get_legal_moves(self, dice).max{ |combo| combo.map {|move| move[1]}.reduce(:+) }
        return false unless amount == max_amount
      end

      moves.each do |move|

        # Validate
        return false unless Board.validate_single_move(move, turn_fields, other_fields)  

        # Make the move on the dupes
        Board.move_single(move, turn_fields, other_fields)
      end
      true
    end

    def self.validate_single_move(move, turn_fields, other_fields)
        from_field = move[0]
        amount = move[1]

        to_field = from_field - amount
        other_to_field = 23 - to_field

        # No checker on field
        return false unless turn_fields[from_field] > 0

        # Hitting wall
        return false unless to_field < 0 || other_fields[other_to_field] < 2

        # Not moving prison checker
        return false if turn_fields[24] > 0 && from_field != 24

        # Bearing off
        if to_field < 0
          return false if Board.last_checker(turn_fields) > 5
          return false if to_field < -1 && from_field != Board.last_checker(turn_fields)
        end
        true
    end

    def self.move_single(move, turn_fields, other_fields)

      from_field = move[0]
      amount = move[1]
      to_field = from_field - amount
      other_to_field = 23 - to_field

      turn_fields[from_field] -= 1
      unless to_field < 0
        turn_fields[to_field] += 1
        if other_fields[other_to_field] == 1
          other_fields[other_to_field] = 0
          other_fields[24] += 1
        end
      end
    end


    private 

    def self.last_checker(fields)
      (0..24).to_a.reverse.each do |index|
        return index if fields[index] > 0
      end
      -1
    end


  end
end