# frozen_string_literal: true

require_relative "../config/application.rb"
require_relative "./person/dealer.rb"
require_relative "./person/player.rb"
require_relative "./person/cpu.rb"
require_relative "./deck.rb"

class Table
  attr_reader :dealer, :players
  def initialize
    @dealer = Dealer.new
    @players = create_players(3)
    @deck = Deck.new
    @deck.shuffle_deck
  end

  def create_players(number)
    players = [Player.new]
    1.upto(number) { |num| players.push(CPU.new(num)) }
    players
  end

  def deal_out_card(person)
    person.receive_card(@deck.deal_out)
  end

  def initial_deal
    1.upto(2) do |num|
      @dealer.initial_receive(@deck.deal_out)
      players.each do |player|
        deal_out_card(player)
      end
    end
  end

  def repeated_decide(person)
    while true
      decide = person.is_a?(CPU) ? person.decide_action(dealer.get_up_card_score) : person.decide_action

      unless person.is_a?(Player)
        puts decide
        sleep SLEEP_SECOND
      end

      if decide == "Hit"
        deal_out_card(person)

        break if person.state == "bust"
      else
        break
      end
    end
  end

  # personがdealerに勝利したのかを返す。またその勝敗にbustが関係しているのかを返す。
  def determine_winner(person)
    person_score = calculate_score(person)
    dealer_score = calculate_score(@dealer)
    # personがbustしてpersonの負け
    if person.is_bust?
      { is_winner: false, is_bust: true, message: "#{person.name}はbustしました。#{person.name}の負けです。" }
    # dealerがbustしてpersonの勝ち
    elsif @dealer.is_bust?
      { is_winner: true, is_bust: true, message: "#{@dealer.name}はbustしました。#{person.name}の勝ちです！" }
    # 双方bustせず点数比較でpersonが勝ち
    elsif person_score > dealer_score
      { is_winner: true, is_bust: false, message: "#{person.name}の得点は#{person_score}点でした。#{person.name}の勝ちです。" }
    # 点数比較でdealerが勝ち
    elsif person_score < dealer_score
      { is_winner: false, is_bust: false, message: "#{person.name}の得点は#{person_score}点でした。#{person.name}の負けです。" }
    # 引き分け
    else
      { winner: nil, is_bust: false, message: "#{person.name}と#{@dealer.name}は同じ点数でした。引き分けです。" }
    end
  end

  def calculate_score(person)
    person.hands.calculate_score
  end
end
