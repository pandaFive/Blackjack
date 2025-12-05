# frozen_string_literal: true

require_relative "test_helper"

class TestGameResult < Minitest::Test
  def setup
    @dealer = Dealer.new
    @player = Player.new
  end

  # Player bust tests
  def test_player_bust
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))
    @player.hands.add_card(Card.new(5, "ダイヤ"))
    @player.hands.state = "bust"

    result = GameResult.new(@dealer, @player)

    assert_equal false, result.is_win
    assert_includes result.message, "bust"
    assert_includes result.message, "負け"
  end

  # Dealer bust tests
  def test_dealer_bust_player_wins
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(10, "ハート"))
    @dealer.hands.add_card(Card.new(5, "ダイヤ"))
    @dealer.hands.state = "bust"

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(7, "ハート"))
    @player.hands.bet(100)

    result = GameResult.new(@dealer, @player)

    assert_equal true, result.is_win
    assert_includes result.message, "ディーラー"
    assert_includes result.message, "bust"
    assert_includes result.message, "勝ち"
    assert_includes result.message, "200ポイント"
  end

  # Surrender tests
  def test_surrender
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(6, "ハート"))
    @player.hands.state = "Surrender"

    result = GameResult.new(@dealer, @player)

    assert_nil result.is_win
    assert_equal "Surrender", result.state
    assert_includes result.message, "Surrender"
    assert_includes result.message, "半分"
  end

  # Score comparison tests
  def test_player_wins_higher_score
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))
    @player.hands.bet(150)

    result = GameResult.new(@dealer, @player)

    assert_equal true, result.is_win
    assert_includes result.message, "20点"
    assert_includes result.message, "勝ち"
    assert_includes result.message, "300ポイント"
  end

  def test_player_loses_lower_score
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(10, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(7, "ハート"))

    result = GameResult.new(@dealer, @player)

    assert_equal false, result.is_win
    assert_includes result.message, "17点"
    assert_includes result.message, "負け"
  end

  def test_draw_same_score
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(8, "ハート"))

    @player.hands.add_card(Card.new(9, "スペード"))
    @player.hands.add_card(Card.new(9, "ハート"))

    result = GameResult.new(@dealer, @player)

    assert_nil result.is_win
    assert_includes result.message, "引き分け"
    assert_includes result.message, "同じ点数"
  end

  # Blackjack tests
  def test_player_blackjack_vs_dealer_20
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(10, "ハート"))

    @player.hands.add_card(Card.new(1, "スペード"))
    @player.hands.add_card(Card.new(11, "ハート"))
    @player.hands.bet(100)

    result = GameResult.new(@dealer, @player)

    assert_equal true, result.is_win
    assert_includes result.message, "21点"
    assert_includes result.message, "勝ち"
    assert_includes result.message, "200ポイント"
  end

  def test_both_blackjack_draw
    @dealer.hands.add_card(Card.new(1, "スペード"))
    @dealer.hands.add_card(Card.new(11, "ハート"))

    @player.hands.add_card(Card.new(1, "ダイヤ"))
    @player.hands.add_card(Card.new(10, "クラブ"))

    result = GameResult.new(@dealer, @player)

    assert_nil result.is_win
    assert_includes result.message, "引き分け"
  end

  # Multiple hands tests
  def test_single_hand_message
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))

    result = GameResult.new(@dealer, @player)

    assert_includes result.message, "あなた"
    refute_includes result.message, "つ目"
  end

  def test_multiple_hands_message
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(8, "スペード"))
    @player.hands.add_card(Card.new(8, "ハート"))
    @player.hands.bet(100)
    @player.split_hands

    result = GameResult.new(@dealer, @player)

    assert_includes result.message, "1つ目の手札"
  end

  # Edge cases
  def test_player_21_with_three_cards
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(9, "ハート"))

    @player.hands.add_card(Card.new(7, "スペード"))
    @player.hands.add_card(Card.new(7, "ハート"))
    @player.hands.add_card(Card.new(7, "ダイヤ"))
    @player.hands.bet(100)

    result = GameResult.new(@dealer, @player)

    assert_equal true, result.is_win
    assert_includes result.message, "21点"
    assert_includes result.message, "200ポイント"
  end

  def test_dealer_17_vs_player_16
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(6, "ハート"))

    result = GameResult.new(@dealer, @player)

    assert_equal false, result.is_win
    assert_includes result.message, "16点"
    assert_includes result.message, "負け"
  end

  def test_person_attribute_in_result
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    @player.hands.add_card(Card.new(10, "スペード"))
    @player.hands.add_card(Card.new(10, "ハート"))

    result = GameResult.new(@dealer, @player)

    assert_equal @player, result.person
  end
end
