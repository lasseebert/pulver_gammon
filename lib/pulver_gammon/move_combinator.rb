module PulverGammon

  class MoveCombinator

    def self.get_legal_moves(board, dice)
      amounts = dice.sort
      amounts = Array.new(4, amounts[0]) if amounts[0] == amounts[1]
      return get_legal_moves_internal(board.fields[board.turn].dup, board.fields[board.turn == :black ? :white : :black].dup, amounts, [])
    end

    private

    def self.get_legal_moves_internal(turn_fields, other_fields, amounts, moves)
      combos = []
      (0..amounts.length - 1).each do |amount_index|

        amount = amounts[amount_index]
        next_amounts = amounts.dup
        next_amounts.slice!(amount_index)

        (0..24).each do |fields_index|
          move = [fields_index, amount]
          if Board.validate_single_move(move, turn_fields, other_fields)
            next_turn_fields = turn_fields.dup
            next_other_fields = other_fields.dup
            Board.move_single move, turn_fields, other_fields

            if next_amounts.length > 0
              combos << (get_legal_moves_internal(next_turn_fields, next_other_fields, next_amounts, moves.dup << move))
            else
              combos << (moves.dup << move)
            end
          end
        end
      end

      combos
    end

  end
  
end