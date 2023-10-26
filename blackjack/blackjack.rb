# frozen_string_literal: true

require_relative "../config/application.rb"
require_relative "./part_class/table.rb"
require_relative "./part_class/game_result.rb"

class Blackjack
  def initialize
    @table = Table.new
    @phase = "continue"
    handle_game_flow
  end

  private
    def handle_game_flow
      while true
        case @phase
        when "continue"
          bet_phase
        when "bet"
          initial_deal_phase
        when "deal"
          player_phase
        when "player"
          dealer_phase
        when "dealer"
          attribute_win_lose_phase
        when "attribute"
          continue_phase
        else
          puts "ブラックジャックを終了します。"
          return
        end
      end
    end

    def bet_phase
      @phase = "bet"
      puts "ブラックジャックを開始します。"
      sleep SLEEP_SECOND
      @table.initialize_table

      @table.players.each { |player| player.bet }
    end

    def initial_deal_phase
      @phase = "deal"
      puts "最初の手札を配ります。"
      sleep SLEEP_SECOND
      @table.initial_deal
    end

    def player_phase
      @phase = "player"
      sleep SLEEP_SECOND

      # アクション選択を繰り返す処理
      @table.players.each { |player| @table.repeated_decide(player) }
    end

    def dealer_phase
      @phase = "dealer"
      dealer = @table.dealer

      dealer.show_second_card
      sleep SLEEP_SECOND
      dealer.score_call

      # ゲーム進行上必要な処理遅延
      sleep SLEEP_SECOND

      # アクション選択を繰り返す処理
      @table.repeated_decide(dealer)
    end

    def attribute_win_lose_phase
      @phase = "attribute"
      results = @table.players.reduce([]) { |array, player| array.push(GameResult.new(@table.dealer, player)) }

      print_game_result(results)
      @table.calculate_bet_payment(results)
      sleep SLEEP_SECOND
    end

    def continue_phase
      @phase = "continue"
      puts ""
      if can_continue?
        ask_continue
      end
    end

    def can_continue?
      @table.players.each do |player|
        if player.chip.zero?
          puts "#{player.name}の所持ポイントが0になりました。\nこれ以上ゲームを続けることはできません。"
          @phase = "end"
          return false
        end
      end
      true
    end

    def ask_continue
      puts "ゲームを続けますか？(y/n)："
      yes_or_no = gets.chomp

      while yes_or_no != "y" && yes_or_no != "n"
        puts "yかnで答えてください。ゲームを続けますか？："
        yes_or_no = gets.chomp
      end

      @phase = "end" if yes_or_no == "n"
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
