# frozen_string_literal: true

require_relative "test_helper"

class TestCPU < Minitest::Test
  def setup
    @cpu = CPU.new(1)
  end

  def test_cpu_initialization
    assert_equal "CPU1", @cpu.name
    assert_equal 10000, @cpu.chip

    cpu2 = CPU.new(2)
    assert_equal "CPU2", cpu2.name
  end

  def test_bet
    @cpu.bet

    assert @cpu.hands.bets > 0
    assert @cpu.chip < 10000
    assert @cpu.hands.bets >= 100 # 10000 / 100
    assert @cpu.hands.bets <= 1000 # 10000 / 10
  end

  # Hard hand tests
  def test_hard_hand_hit_when_8_or_below
    @cpu.hands.add_card(Card.new(3, "スペード"))
    @cpu.hands.add_card(Card.new(5, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Hit", result
  end

  def test_hard_hand_stand_when_17_or_above
    @cpu.hands.add_card(Card.new(10, "スペード"))
    @cpu.hands.add_card(Card.new(7, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Stand", result
  end

  def test_hard_hand_double_down_9_vs_3to6
    @cpu.hands.add_card(Card.new(5, "スペード"))
    @cpu.hands.add_card(Card.new(4, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(5)
    assert_equal "Double Down", result
  end

  def test_hard_hand_double_down_10_vs_2to9
    @cpu.hands.add_card(Card.new(6, "スペード"))
    @cpu.hands.add_card(Card.new(4, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(7)
    assert_equal "Double Down", result
  end

  def test_hard_hand_double_down_11_vs_2to10
    @cpu.hands.add_card(Card.new(6, "スペード"))
    @cpu.hands.add_card(Card.new(5, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(10)
    assert_equal "Double Down", result
  end

  def test_hard_hand_surrender_16_vs_9_or_above
    @cpu.hands.add_card(Card.new(10, "スペード"))
    @cpu.hands.add_card(Card.new(6, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Surrender", result
  end

  def test_hard_hand_hit_12to16_vs_7_or_above
    @cpu.hands.add_card(Card.new(10, "スペード"))
    @cpu.hands.add_card(Card.new(5, "ハート"))

    result = @cpu.decide_action(8)
    assert_equal "Hit", result
  end

  def test_hard_hand_stand_12to16_vs_2to6
    @cpu.hands.add_card(Card.new(10, "スペード"))
    @cpu.hands.add_card(Card.new(5, "ハート"))

    result = @cpu.decide_action(5)
    assert_equal "Stand", result
  end

  # Soft hand tests (with Ace as 11)
  def test_soft_hand_hit_when_17_or_below
    @cpu.hands.add_card(Card.new(1, "スペード")) # A
    @cpu.hands.add_card(Card.new(6, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Hit", result
  end

  def test_soft_hand_stand_when_19_or_above
    @cpu.hands.add_card(Card.new(1, "スペード")) # A
    @cpu.hands.add_card(Card.new(8, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Stand", result
  end

  def test_soft_hand_hit_18_vs_9_or_above
    @cpu.hands.add_card(Card.new(1, "スペード")) # A
    @cpu.hands.add_card(Card.new(7, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Hit", result
  end

  def test_soft_hand_stand_18_vs_8_or_below
    @cpu.hands.add_card(Card.new(1, "スペード")) # A
    @cpu.hands.add_card(Card.new(7, "ハート"))

    result = @cpu.decide_action(7)
    assert_equal "Stand", result
  end

  # Split tests
  def test_split_aces
    @cpu.hands.add_card(Card.new(1, "スペード"))
    @cpu.hands.add_card(Card.new(1, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(10)
    assert_equal "Split", result
  end

  def test_split_eights
    @cpu.hands.add_card(Card.new(8, "スペード"))
    @cpu.hands.add_card(Card.new(8, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(10)
    assert_equal "Split", result
  end

  def test_split_nines_vs_2to6_or_8to9
    @cpu.hands.add_card(Card.new(9, "スペード"))
    @cpu.hands.add_card(Card.new(9, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(5)
    assert_equal "Split", result

    @cpu.initialize_person
    @cpu.hands.add_card(Card.new(9, "スペード"))
    @cpu.hands.add_card(Card.new(9, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(8)
    assert_equal "Split", result
  end

  def test_no_split_nines_vs_7_10_or_11
    @cpu.hands.add_card(Card.new(9, "スペード"))
    @cpu.hands.add_card(Card.new(9, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(10)
    assert_equal "Stand", result
  end

  def test_split_sevens_vs_2to7
    @cpu.hands.add_card(Card.new(7, "スペード"))
    @cpu.hands.add_card(Card.new(7, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(6)
    assert_equal "Split", result
  end

  def test_no_split_sevens_vs_8_or_above
    @cpu.hands.add_card(Card.new(7, "スペード"))
    @cpu.hands.add_card(Card.new(7, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(9)
    assert_equal "Hit", result
  end

  def test_split_sixes_vs_3to6
    @cpu.hands.add_card(Card.new(6, "スペード"))
    @cpu.hands.add_card(Card.new(6, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(5)
    assert_equal "Split", result
  end

  def test_no_split_sixes_vs_2_or_7_or_above
    @cpu.hands.add_card(Card.new(6, "スペード"))
    @cpu.hands.add_card(Card.new(6, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(2)
    assert_equal "Hit", result
  end

  def test_split_threes_vs_4to7
    @cpu.hands.add_card(Card.new(3, "スペード"))
    @cpu.hands.add_card(Card.new(3, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(6)
    assert_equal "Split", result
  end

  def test_split_twos_vs_4to7
    @cpu.hands.add_card(Card.new(2, "スペード"))
    @cpu.hands.add_card(Card.new(2, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(5)
    assert_equal "Split", result
  end

  def test_double_down_fives_vs_2to9
    @cpu.hands.add_card(Card.new(5, "スペード"))
    @cpu.hands.add_card(Card.new(5, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(7)
    assert_equal "Double Down", result
  end

  def test_no_split_fives_vs_10_or_11
    @cpu.hands.add_card(Card.new(5, "スペード"))
    @cpu.hands.add_card(Card.new(5, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(10)
    assert_equal "Hit", result
  end

  def test_no_split_fours
    @cpu.hands.add_card(Card.new(4, "スペード"))
    @cpu.hands.add_card(Card.new(4, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(5)
    assert_equal "Hit", result
  end

  def test_no_split_tens
    @cpu.hands.add_card(Card.new(10, "スペード"))
    @cpu.hands.add_card(Card.new(10, "ハート"))
    @cpu.hands.bet(100)

    result = @cpu.decide_action(6)
    assert_equal "Stand", result
  end

  # Test state is set
  def test_decide_action_sets_state
    @cpu.hands.add_card(Card.new(10, "スペード"))
    @cpu.hands.add_card(Card.new(7, "ハート"))

    result = @cpu.decide_action(10)
    assert_equal "Stand", result
    assert_equal "Stand", @cpu.hands.state
  end
end
