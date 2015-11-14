class BowlingGame
  FRAMES_LIMIT = 10

  class Frame
    attr_accessor :rolls

    def initialize
      @rolls = []
    end

    def sum
      @rolls.inject(0, &:+)
    end

    def first_roll
      @rolls[0].to_i
    end

    def first_roll?
      @rolls[0].nil?
    end

    def spare?
      return false if @rolls[1].nil?
      @rolls[0] + @rolls[1] == 10
    end

    def strike?
      @rolls[0] == 10
    end
  end

  attr_accessor :frames

  def initialize
    @current_frame = Frame.new
    @frames = [@current_frame]
  end

  def score
    @frames.take(FRAMES_LIMIT).each_index.inject(0) do |acc, index|
       res = if @frames[index].strike?
              if @frames[index + 1].strike?
                @frames[index].sum + @frames[index + 1].sum + @frames[index + 2].first_roll
              else
                @frames[index].sum + @frames[index + 1].sum
              end
            elsif @frames[index].spare?
              @frames[index].sum + @frames[index + 1].first_roll
            else
              @frames[index].sum
            end

      acc + res
    end
  end

  def roll(pins)
    if @current_frame.first_roll? && !strike?(pins)
      @current_frame.rolls << pins
    else
      @current_frame.rolls << pins
      @current_frame = Frame.new
      @frames << @current_frame
    end
  end

  def strike?(pins)
    pins == 10
  end
end

BowlingGame.new

require 'minitest/autorun'
require 'minitest/reporters'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class TestBowlingGame < MiniTest::Test
  def setup
    @bowling_game = BowlingGame.new
  end

  def test_rolls
    # frame 1 - strike
    assert_equal @bowling_game.frames.size, 1
    @bowling_game.roll(10)
    assert_equal @bowling_game.frames[0].rolls, [10]
    assert_equal @bowling_game.frames.size, 2
    # frame 2 - spare
    assert_equal @bowling_game.frames.size, 2
    @bowling_game.roll(5)
    assert_equal @bowling_game.frames[1].rolls, [5]
    assert_equal @bowling_game.frames.size, 2
    @bowling_game.roll(5)
    assert_equal @bowling_game.frames[1].rolls, [5, 5]
    assert_equal @bowling_game.frames.size, 3
    # frame 3 - open
    assert_equal @bowling_game.frames.size, 3
    @bowling_game.roll(1)
    assert_equal @bowling_game.frames[2].rolls, [1]
    assert_equal @bowling_game.frames.size, 3
    @bowling_game.roll(4)
    assert_equal @bowling_game.frames[2].rolls, [1, 4]
    assert_equal @bowling_game.frames.size, 4
  end

  def test_open_frame
    assert_equal @bowling_game.score, 0
    @bowling_game.roll(1)
    assert_equal @bowling_game.score, 1
    @bowling_game.roll(2)
    assert_equal @bowling_game.score, 3
    @bowling_game.roll(3)
    assert_equal @bowling_game.score, 6
    @bowling_game.roll(4)
    assert_equal @bowling_game.score, 10
    @bowling_game.roll(3)
    assert_equal @bowling_game.score, 13
    @bowling_game.roll(3)
    assert_equal @bowling_game.score, 16
  end

  def test_spare_frame
    # frame 1 - spare
    assert_equal @bowling_game.score, 0
    @bowling_game.roll(5)
    assert_equal @bowling_game.score, 5
    @bowling_game.roll(5)
    assert_equal @bowling_game.score, 10
    # frame 2 - spare
    @bowling_game.roll(4)
    assert_equal @bowling_game.score, 18
    @bowling_game.roll(6)
    assert_equal @bowling_game.score, 24
    # frame 3 - open
    @bowling_game.roll(1)
    assert_equal @bowling_game.score, 26
  end

  def test_strike_frame
    # frame 1 - strike
    assert_equal @bowling_game.score, 0
    @bowling_game.roll(10)
    assert_equal @bowling_game.score, 10
    # frame 2 - strike
    @bowling_game.roll(10)
    assert_equal @bowling_game.score, 30
    # frame 3 - open
    @bowling_game.roll(5)
    assert_equal @bowling_game.score, 45
    @bowling_game.roll(4)
    assert_equal @bowling_game.score, 53
  end

  def test_full_game
    # frame 1 - strike
    @bowling_game.roll(10)
    # frame 2 - spare
    @bowling_game.roll(9)
    @bowling_game.roll(1)
    # frame 3 - spare
    @bowling_game.roll(5)
    @bowling_game.roll(5)
    # frame 4 - open
    @bowling_game.roll(7)
    @bowling_game.roll(2)
     # frame 5 - strike
    @bowling_game.roll(10)
     # frame 6 - strike
    @bowling_game.roll(10)
     # frame 7 - strike
    @bowling_game.roll(10)
     # frame 8 - open
    @bowling_game.roll(9)
    @bowling_game.roll(0)
     # frame 9 - spare
    @bowling_game.roll(8)
    @bowling_game.roll(2)
     # frame 10 - spare + strike
    @bowling_game.roll(9)
    @bowling_game.roll(1)
    @bowling_game.roll(10)
    assert_equal @bowling_game.score, 187
  end
end
