# frozen_string_literal: true

require_relative "test_helper"
require "stringio"

class TestPlayer < Minitest::Test
  def setup
    @player = Player.new
  end

  def test_player_initialization
    assert_equal "あなた", @player.name
    assert_equal 10000, @player.chip
  end

  def test_bet_valid_amount
    @player.stub :gets, -> { "500\n" } do
      @player.bet
    end

    assert_equal 500, @player.hands.bets
    assert_equal 9500, @player.chip
  end

  def test_bet_boundary_minimum
    @player.stub :gets, -> { "1\n" } do
      @player.bet
    end

    assert_equal 1, @player.hands.bets
    assert_equal 9999, @player.chip
  end

  def test_bet_boundary_maximum
    @player.stub :gets, -> { "10000\n" } do
      @player.bet
    end

    assert_equal 10000, @player.hands.bets
    assert_equal 0, @player.chip
  end

  def test_bet_invalid_then_valid
    inputs = ["0\n", "11000\n", "-5\n", "100\n"]
    @player.stub :gets, -> { inputs.shift } do
      @player.bet
    end

    assert_equal 100, @player.hands.bets
    assert_equal 9900, @player.chip
  end

  def test_decide_action_hit
    @player.hands.add_card(Card.new(5, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))

    result = @player.stub :gets, -> { "Hit\n" } do
      @player.decide_action
    end

    assert_equal "Hit", result
    assert_equal "Hit", @player.hands.state
  end

  def test_decide_action_stand
    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(9, "ハート"))

    result = @player.stub :gets, -> { "Stand\n" } do
      @player.decide_action
    end

    assert_equal "Stand", result
    assert_equal "Stand", @player.hands.state
  end

  def test_decide_action_surrender
    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(6, "ハート"))

    result = @player.stub :gets, -> { "Surrender\n" } do
      @player.decide_action
    end

    assert_equal "Surrender", result
    assert_equal "Surrender", @player.hands.state
  end

  def test_decide_action_double_down
    @player.hands.add_card(Card.new(5, "スペード"))
    @player.hands.add_card(Card.new(6, "ハート"))
    @player.hands.bet(100)

    result = @player.stub :gets, -> { "Double Down\n" } do
      @player.decide_action
    end

    assert_equal "Double Down", result
    assert_equal "Double Down", @player.hands.state
  end

  def test_decide_action_split
    @player.hands.add_card(Card.new(8, "スペード"))
    @player.hands.add_card(Card.new(8, "ハート"))
    @player.hands.bet(100)

    result = @player.stub :gets, -> { "Split\n" } do
      @player.decide_action
    end

    assert_equal "Split", result
    assert_equal "Split", @player.hands.state
  end

  def test_decide_action_invalid_then_valid
    @player.hands.add_card(Card.new(5, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))

    # Invalid options for this hand: Surrender (needs 2 cards initially), Double Down (needs exactly 2 cards and enough chips)
    # Valid options: Hit, Stand
    inputs = ["Invalid\n", "Hit\n"]
    result = @player.stub :gets, -> { inputs.shift } do
      @player.decide_action
    end

    assert_equal "Hit", result
  end

  def test_create_action_message_single_hand
    @player.hands.add_card(Card.new(5, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))

    message = @player.send(:create_action_message)

    assert_includes message, "あなた"
    assert_includes message, "15"
    assert_includes message, "Hit"
    assert_includes message, "Stand"
  end

  def test_create_action_message_multiple_hands
    @player.hands.add_card(Card.new(8, "スペード"))
    @player.hands.add_card(Card.new(8, "ハート"))
    @player.hands.bet(100)
    @player.split_hands

    message = @player.send(:create_action_message)

    assert_includes message, "1つ目の手札"
  end

  def test_get_available_options_basic
    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(5, "ハート"))
    @player.hands.add_card(Card.new(3, "ダイヤ"))

    options = @player.send(:get_available_options)

    assert_includes options, "Hit"
    assert_includes options, "Stand"
    refute_includes options, "Surrender"
    refute_includes options, "Double Down"
    refute_includes options, "Split"
  end

  def test_get_available_options_with_surrender
    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(6, "ハート"))

    options = @player.send(:get_available_options)

    assert_includes options, "Surrender"
  end

  def test_get_available_options_with_double_down
    @player.hands.add_card(Card.new(5, "スペード"))
    @player.hands.add_card(Card.new(6, "ハート"))
    @player.hands.bet(100)

    options = @player.send(:get_available_options)

    assert_includes options, "Double Down"
  end

  def test_get_available_options_with_split
    @player.hands.add_card(Card.new(8, "スペード"))
    @player.hands.add_card(Card.new(8, "ハート"))
    @player.hands.bet(100)

    options = @player.send(:get_available_options)

    assert_includes options, "Split"
  end
end
