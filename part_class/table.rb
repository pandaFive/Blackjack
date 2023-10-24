# frozen_string_literal: true

require_relative "../config/application.rb"
require_relative "./person/dealer.rb"
require_relative "./person/player.rb"
require_relative "./deck.rb"

class Table
  attr_reader :dealer, :player
  def initialize
    @dealer = Dealer.new
    @player = Player.new
    @deck = Deck.new
    @deck.shuffle_deck
  end

  def deal_out_card(person)
    person.receive_card(@deck.deal_out)
  end

  def initial_deal
    1.upto(2) do |num|
      @dealer.initial_receive(@deck.deal_out)
      deal_out_card(@player)
    end
  end

  def repeated_decide(person)
    while true
      if person.decide_action == "Hit"
        deal_out_card(person)

        break if person.state == "bust"
      else
        break
      end
      sleep SLEEP_SECOND
    end
  end

  def determine_winner(person)
    person_score = calculate_score(person)
    dealer_score = calculate_score(@dealer)
    # personがbustしてpersonの負け
    if person.is_bust?
      { winner: @dealer, is_bust: true, message: "#{person.name}はbustしました。#{person.name}の負けです。" }
    # dealerがbustしてpersonの勝ち
    elsif @dealer.is_bust?
      { winner: person, is_bust: true, message: "#{@dealer.name}はbustしました。#{person.name}の勝ちです！" }
    # 双方bustせず点数比較でpersonが勝ち
    elsif person_score > dealer_score
      { winner: person, is_bust: false, message: "#{person.name}の勝ちです。" }
    # 点数比較でdealerが勝ち
    elsif person_score < dealer_score
      { winner: @dealer, is_bust: false, message: "#{person.name}の負けです。" }
    # 引き分け
    else
      { winner: nil, is_bust: false, message: "#{person.name}と#{@dealer.name}は同じ点数でした。引き分けです。" }
    end
  end

  def calculate_score(person)
    person.hands.calculate_score
  end
end
