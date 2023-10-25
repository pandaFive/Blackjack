# frozen_string_literal: true

require_relative "./config/application.rb"
require_relative "./part_class/table.rb"
require_relative "./part_class/game_result.rb"

class Blackjack
  def initialize
    @table = Table.new
    @phase = "initial"
  end

  def handle_game_flow
    while true
      case @phase
      when "initial"
        @phase = initial_phase
      when "bet"
        @phase = bet_phase
      when "player"
        @phase = player_phase
      when "dealer"
        @phase = dealer_phase
      when "attribute"
        @phase = attribute_win_lose_phase
      else
        puts "ブラックジャックを終了します。"
        return
      end
    end
  end

  def initial_phase
    puts "ブラックジャックを開始します。"
    sleep SLEEP_SECOND
    @table.initial_deal

    "bet"
  end

  def bet_phase
    sleep SLEEP_SECOND

    @table.players.each { |player| player.bet }

    "player"
  end

  def player_phase
    sleep SLEEP_SECOND

    # アクション選択を繰り返す処理
    @table.players.each { |player| @table.repeated_decide(player) }

    "dealer"
  end

  def dealer_phase
    dealer = @table.dealer

    dealer.show_second_card
    sleep SLEEP_SECOND
    dealer.score_call

    # ゲーム進行上必要な処理遅延
    sleep SLEEP_SECOND

    # アクション選択を繰り返す処理
    @table.repeated_decide(dealer)

    "attribute"
  end

  def attribute_win_lose_phase
    # results = @table.players.reduce([]) { |array, player| array.push(@table.determine_winner(player)) }
    results = @table.players.reduce([]) { |array, player| array.push(GameResult.new(@table.dealer, player)) }

    print_game_result(results)
    calculate_bet_payment(results)
    sleep SLEEP_SECOND
    "end"
  end

  def calculate_bet_payment(results)
    results.each do |result|
      person = result.person
      if result.is_win
        person.add_chip(person.bets * 2)
      # 引き分けかSurrender
      elsif result.is_win == nil
        if person.state == "Surrender"
          person.add_chip((person.bets / 2).to_i)
        else
          person.add_chip(person.bets)
        end
      end
      person.reset_bets
      person.show_points
    end
  end

  def print_game_result(results)
    puts "ディーラーの得点は#{@table.calculate_score(@table.dealer)}点でした。"
    sleep SLEEP_SECOND
    results.each do |result|
      puts result.message
      sleep SLEEP_SECOND
    end
  end
end

blackjack = Blackjack.new
blackjack.handle_game_flow
