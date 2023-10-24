# frozen_string_literal: true

# 末尾呼び出し最適化を試す。いったん脇に置いておく。
# RubyVM::InstructionSequence.compile_option = {
#   tailcall_optimization: true,
#   trace_instruction: false
# }

require_relative "./config/application.rb"
require_relative "./part_class/table.rb"

class Blackjack
  def initialize
    @table = Table.new
    @phase = "initial"
  end

  def handle_game_flow(phase)
    case phase
    when "initial"
      handle_game_flow(initial_phase)
    when "bet"
      handle_game_flow(bet_phase)
    when "player"
      handle_game_flow(player_phase)
    when "dealer"
      handle_game_flow(dealer_phase)
    when "attribute"
      handle_game_flow(attribute_win_lose_phase)
    else
      puts "ブラックジャックを終了します。"
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
    results = @table.players.reduce([]) { |array, player| array.push(@table.determine_winner(player)) }

    notice_result(results)
    settle_bets(results)
    sleep SLEEP_SECOND
    "end"
  end

  def settle_bets(results)
    results.each do |result|
      person = result[:person]
      if result[:is_win]
        person.add_chip(person.bets * 2)
      elsif result[:is_win] == nil
        person.add_chip(person.bets)
      end
      person.reset_bets
    end
  end

  def notice_result(results)
    puts "ディーラーの得点は#{@table.calculate_score(@table.dealer)}点でした。"
    sleep SLEEP_SECOND
    results.each do |result|
      puts result[:message]
      sleep SLEEP_SECOND
    end
  end
end

blackjack = Blackjack.new
blackjack.handle_game_flow("initial")
