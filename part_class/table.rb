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
      deal_out_card(@dealer)
      deal_out_card(@player)
      sleep SLEEP_SECOND
    end
    @dealer.show_up_card
  end
end
