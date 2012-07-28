module PulverGammon
  class Board

    # The board in the form:
    # {black: [checkers], white: [checkers]}
    # Checkers is an array of length 25:
    # Index 0: Prison
    # Index 1-24: Normal fields where 19-24 is the home board
    attr_accessor :fields

    # The next player to move
    attr_accessor :turn

    def initialize(start_turn)
      self.fields = {black: Array.new(25, 0), white: Array.new(25, 0)}
      fields[:black][1] = 2
      fields[:black][12] = 5
      fields[:black][17] = 3
      fields[:black][19] = 5
      fields[:white][1] = 2
      fields[:white][12] = 5
      fields[:white][17] = 3
      fields[:white][19] = 5

      self.turn = start_turn
    end
  end
end