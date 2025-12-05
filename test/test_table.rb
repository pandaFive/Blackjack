# frozen_string_literal: true

require_relative "test_helper"
require "stringio"

class TestTable < Minitest::Test
  def setup
    @table = Table.new
  end

  def test_table_initialization
    assert_instance_of Dealer, @table.dealer
    assert_equal 3, @table.players.length
    assert_instance_of Player, @table.players[0]
    assert_instance_of CPU, @table.players[1]
    assert_instance_of CPU, @table.players[2]
  end

  def test_initialize_table
    # Deal some cards first
    @table.deal_out_card(@table.dealer)
    @table.deal_out_card(@table.players[0])

    # Reinitialize
    @table.initialize_table

    # Check that hands are cleared
    @table.players.each do |player|
      assert_equal 1, player.hands_array.length
      assert_empty player.hands.hands
    end
  end

  def test_deal_out_card
    player = @table.players[0]
    initial_count = player.hands.length

    @table.deal_out_card(player)

    assert_equal initial_count + 1, player.hands.length
  end

  def test_initial_deal
    @table.initial_deal

    # Dealer should have 2 cards
    assert_equal 2, @table.dealer.hands.length

    # Each player should have 2 cards
    @table.players.each do |player|
      assert_equal 2, player.hands.length
    end
  end

  def test_calculate_score
    player = @table.players[0]
    player.hands.add_card(Card.new(10, "スペード"))
    player.hands.add_card(Card.new(7, "ハート"))

    score = @table.calculate_score(player)
    assert_equal 17, score
  end

  def test_calculate_bet_payment_win
    dealer = @table.dealer
    dealer.hands.add_card(Card.new(10, "スペード"))
    dealer.hands.add_card(Card.new(7, "ハート"))

    player = @table.players[0]
    initial_chip = player.chip
    player.hands.add_card(Card.new(10, "スペード"))
    player.hands.add_card(Card.new(10, "ハート"))
    player.hands.bet(100)
    player.add_chip(-100) # Simulate chip deduction from betting

    results = [[GameResult.new(dealer, player)]]

    @table.calculate_bet_payment(results)

    # Player should receive 200 points (bet * 2), but already paid 100
    # So net gain is 100 (initial - 100 bet + 200 payout = initial + 100)
    assert_equal initial_chip + 100, player.chip
  end

  def test_calculate_bet_payment_lose
    dealer = @table.dealer
    dealer.hands.add_card(Card.new(10, "スペード"))
    dealer.hands.add_card(Card.new(10, "ハート"))

    player = @table.players[0]
    initial_chip = player.chip
    player.hands.add_card(Card.new(10, "スペード"))
    player.hands.add_card(Card.new(7, "ハート"))
    player.hands.bet(100)
    player.add_chip(-100) # Simulate chip deduction from betting

    results = [[GameResult.new(dealer, player)]]

    @table.calculate_bet_payment(results)

    # Player loses, loses the 100 bet
    assert_equal initial_chip - 100, player.chip
  end

  def test_calculate_bet_payment_draw
    dealer = @table.dealer
    dealer.hands.add_card(Card.new(10, "スペード"))
    dealer.hands.add_card(Card.new(8, "ハート"))

    player = @table.players[0]
    initial_chip = player.chip
    player.hands.add_card(Card.new(9, "スペード"))
    player.hands.add_card(Card.new(9, "ハート"))
    player.hands.bet(100)
    player.add_chip(-100) # Simulate chip deduction from betting

    results = [[GameResult.new(dealer, player)]]

    @table.calculate_bet_payment(results)

    # Player gets bet back, so net zero
    assert_equal initial_chip, player.chip
  end

  def test_calculate_bet_payment_surrender
    dealer = @table.dealer
    dealer.hands.add_card(Card.new(10, "スペード"))
    dealer.hands.add_card(Card.new(10, "ハート"))

    player = @table.players[0]
    initial_chip = player.chip
    player.hands.add_card(Card.new(10, "スペード"))
    player.hands.add_card(Card.new(6, "ハート"))
    player.hands.bet(100)
    player.add_chip(-100) # Simulate chip deduction from betting
    player.hands.state = "Surrender"

    results = [[GameResult.new(dealer, player)]]

    @table.calculate_bet_payment(results)

    # Player gets half of bet back (50), so net loss of 50
    assert_equal initial_chip - 50, player.chip
  end

  def test_behavior_split
    player = @table.players[0]
    player.hands.add_card(Card.new(8, "スペード"))
    player.hands.add_card(Card.new(8, "ハート"))
    player.hands.bet(100)

    # Mock the repeated_decide method to prevent infinite loop
    def @table.repeated_decide(person)
      # Do nothing for test
    end

    @table.send(:behavior_split, player)

    # Player should have 2 hands now
    assert_equal 2, player.hands_array.length
  end

  def test_double_down_bet_through_table
    player = @table.players[0]
    player.hands.add_card(Card.new(5, "スペード"))
    player.hands.add_card(Card.new(6, "ハート"))
    player.hands.bet(100)

    initial_chip = player.chip

    # Simulate double down
    player.stub :gets, -> { "Double Down\n" } do
      decide = player.decide_action
      if decide == "Double Down"
        player.double_down_bet
        @table.deal_out_card(player)
      end
    end

    assert_equal 200, player.hands.bets
    assert_equal initial_chip - 100, player.chip
    assert_equal 3, player.hands.length
  end

  # Note: repeated_decide tests are complex and require mocking the dealer's up card
  # These tests are omitted for simplicity

  def test_players_include_one_human_and_two_cpus
    assert_instance_of Player, @table.players[0]
    assert_instance_of CPU, @table.players[1]
    assert_instance_of CPU, @table.players[2]
    assert_equal "あなた", @table.players[0].name
    assert_equal "CPU1", @table.players[1].name
    assert_equal "CPU2", @table.players[2].name
  end
end
