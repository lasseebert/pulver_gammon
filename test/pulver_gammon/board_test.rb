require 'test_helper'
require 'pulver_gammon/board'

class TestBoard < Test::Unit::TestCase
  
  def test_initialize
    expected_fields = {
      1 => 2,
      12 => 5,
      17 => 3,
      19 => 5
    }

    board = PulverGammon::Board.new(:black)
    
    assert_equal 2, board.fields.length
    assert_equal 25, board.fields[:white].length
    assert_equal 25, board.fields[:black].length
    (0..24).each do |index|
      assert_equal expected_fields[index] || 0, board.fields[:white][index]
      assert_equal expected_fields[index] || 0, board.fields[:black][index]
    end

    assert_equal :black, board.turn

  end

end