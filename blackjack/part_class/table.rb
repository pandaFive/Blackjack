# frozen_string_literal: true

require_relative "../../config/application.rb"
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
    initialize_table
  end

  def initialize_table
    @deck = Deck.new
    @deck.shuffle_deck

    @dealer.initialize_person
    players.each { |player| player.initialize_person }
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

        break if person.hands.state == "bust"
      elsif decide == "Double Down"
        puts "#{person.name}は追加のポイントをbetしました。"
        person.double_down_bet
        deal_out_card(person)
        break
      elsif decide == "Split"
        behavior_split(person)
        break
      else
        break
      end
    end
  end

  def behavior_split(person)
    person.split_hands
    puts "#{person.name}は追加のポイントをbetしました。"
    current_length = person.hands_number

    person.get_hands_index.upto(person.hands_number - 1) do |num|
      puts "#{person.name}の#{num + 1}つ目の手札に追加のカードを配ります。"
      sleep SLEEP_SECOND
      deal_out_card(person)
      repeated_decide(person)
      sleep SLEEP_SECOND
      person.switching_hands
      # splitを2回以上行った時にこの関数を多重に呼び出して多重に手札の処理をすることを防ぐための処理
      break if current_length != person.hands_number
    end
  end

  def calculate_score(person)
    person.hands.calculate_score
  end

  def calculate_bet_payment(results)
    # results = [[GameResult, GameResult], [GameResult], [GameResult]]
    # results.length == table.players.length
    # results[x].length == table.players[x].hands_array.length

    # playerを取り出している
    results.each do |player|
      # 手札ごとの結果を取り出している
      player.each do |result|
        target_player = result.person
        if result.is_win
          target_player.add_chip_win
        # 引き分けかSurrender
        elsif result.is_win == nil
          if result.state == "Surrender"
            target_player.add_chip_surrender
          else
            target_player.add_chip_draw
          end
        end
      end
      player[0].person.show_points
      sleep SLEEP_SECOND
    end
  end

  private
    def create_players(number)
      players = [Player.new]
      1.upto(number) { |num| players.push(CPU.new(num)) }
      players
    end
end
