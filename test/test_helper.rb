# frozen_string_literal: true

require "minitest/autorun"
require_relative "../config/application.rb"
require_relative "../blackjack/part_class/card.rb"
require_relative "../blackjack/part_class/deck.rb"
require_relative "../blackjack/part_class/hands.rb"
require_relative "../blackjack/part_class/person.rb"
require_relative "../blackjack/part_class/person/player.rb"
require_relative "../blackjack/part_class/person/dealer.rb"
require_relative "../blackjack/part_class/person/cpu.rb"
require_relative "../blackjack/part_class/game_result.rb"
require_relative "../blackjack/part_class/table.rb"

# Suppress output during testing
module SilentOutput
  def puts(*args)
    # Do nothing
  end

  def print(*args)
    # Do nothing
  end

  def sleep(*args)
    # Do nothing
  end
end

# Apply silent output to all classes during testing
[Person, Player, Dealer, CPU, Card, Deck, Hands, Table, GameResult].each do |klass|
  klass.prepend(SilentOutput)
end
