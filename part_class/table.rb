# frozen_string_literal: true

require_relative "../config/application.rb"
require_relative "./person/dealer.rb"
require_relative "./person/player.rb"
require_relative "./person/cpu.rb"
require_relative "./deck.rb"
require_relative "./game_result.rb"

class Table
  attr_reader :dealer, :players
  def initialize
    @dealer = Dealer.new
    @players = create_players(2)
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

  def calculate_score(person)
    person.hands.calculate_score
  end
end
