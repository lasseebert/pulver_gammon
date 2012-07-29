require 'test_helper'
require 'pulver_gammon/board'

class TestBoard < Test::Unit::TestCase
  
  def setup
    @board = PulverGammon::Board.new(:black)
  end

  def set_board(black = {}, white = {})
    @board.fields = { black: [], white: [] }
    (0..24).each do |index|
      @board.fields[:black] << (black[index] || 0)
      @board.fields[:white] << (white[index] || 0)
    end
  end

  def test_initialize
    expected_fields = {
      5 => 5,
      7 => 3,
      12 => 5,
      23 => 2
    }

    assert_equal 2, @board.fields.length
    assert_equal 25, @board.fields[:white].length
    assert_equal 25, @board.fields[:black].length
    (0..24).each do |index|
      assert_equal expected_fields[index] || 0, @board.fields[:white][index]
      assert_equal expected_fields[index] || 0, @board.fields[:black][index]
    end

    assert_equal :black, @board.turn

  end


  def test_move
    @board.move([[5, 2], [12, 4]], [2, 4])

    assert_equal 1, @board.fields[:black][3]
    assert_equal 4, @board.fields[:black][5]
    assert_equal 1, @board.fields[:black][8]
    assert_equal 4, @board.fields[:black][12]

    assert_equal :white, @board.turn
  end

  def test_move_hit
    set_board({9 => 1, 10 => 1}, {17 => 1})

    @board.move([[9, 3], [10, 4]], [3, 4])

    assert_equal 0, @board.fields[:white][17]
    assert_equal 2, @board.fields[:black][6]
    assert_equal 0, @board.fields[:black][9]
    assert_equal 0, @board.fields[:black][10]
  end

  def test_move_home
    set_board({2 => 2, 3 => 2}, {17 => 15})

    @board.move([[3, 4], [2, 3]], [3, 4])

    assert_equal 1, @board.fields[:black][2]
    assert_equal 1, @board.fields[:black][3]
  end


  def test_validate_true
    assert @board.validate_move([[5, 2], [12, 4]], [2, 4])
  end

  def test_validate_missing_checker
    assert_false @board.validate_move([[13, 3]], [3])
  end

  def test_validate_not_match_dice
    assert_false @board.validate_move([[12, 3]], [4])
  end

  def test_validate_hitting_wall
    assert_false @board.validate_move([[12, 1]], [1])
  end
  def test_validate_missing_hitting_single
    set_board({5 => 1}, {19 => 1})
    assert @board.validate_move([[5, 1]], [1])
  end

  def test_validate_not_using_largest_dice_amount
    set_board({ 5 => 1 }, { 22 => 2, 23 => 2 })
    assert_false @board.validate_move([[5, 2]], [2, 3])

    set_board({ 5 => 1 }, { 22 => 2, 23 => 2 })
    assert @board.validate_move([[5, 3]], [2, 3])
  end

  def test_validate_not_use_all_dice
    assert_false @board.validate_move([[12, 3]], [2, 3])
  end

  def test_validate_use_all_dice_on_double
    assert @board.validate_move([[12, 3], [12, 3], [12, 3], [12, 3]], [3, 3])
  end
  def test_validate_not_use_all_dice_on_double
    assert_false @board.validate_move([[12, 3], [12, 3], [12, 3]], [3, 3])
  end

  def test_validate_not_moving_prison_checker
    set_board({23 => 1, 24 => 1})
    assert_false @board.validate_move([[23, 1]], [1])
  end

  def test_validate_moving_prison_checker
    set_board({23 => 1, 24 => 1})
    assert @board.validate_move([[24, 1]], [1])
  end

  def test_validate_no_moves
    set_board({24 => 1}, { 0 => 2})
    assert @board.validate_move([], [1, 1])
  end

  def test_validate_move_checker_twice
    assert @board.validate_move([[12, 2], [10, 4]], [2, 4])
  end

  def test_validate_should_not_move_board
    assert @board.validate_move([[12, 2], [10, 4]], [2, 4])
    assert_equal 5, @board.fields[:black][12]
  end

  def test_validate_bear_off_with_checkers_outside_home
    set_board({0 => 1, 6 => 1})
    assert_false @board.validate_move([[0, 1]], [1])
  end

  def test_validate_bear_off_without_checkers_outside_home
    set_board({0 => 1, 5 => 1})
    assert @board.validate_move([[0, 1]], [1])
  end

  def test_validate_bear_off_with_too_large_dice_correct
    set_board({0 => 1, 1 => 1})
    assert_false @board.validate_move([[0, 6]], [6])
  end

  def test_validate_bear_off_with_too_large_dice_incorrect
    set_board({0 => 1, 1 => 1})
    assert @board.validate_move([[1, 6]], [6])
  end

end