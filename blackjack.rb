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
    if phase == "initial"
      handle_game_flow(initial_phase)
    elsif phase == "player"
      handle_game_flow(player_phase)
    elsif phase == "dealer"
      handle_game_flow(dealer_phase)
    else
      puts "ブラックジャックを終了します。"
    end
  end

  def initial_phase
    puts "ブラックジャックを開始します。"
    sleep SLEEP_SECOND
    @table.initial_deal

    "player"
  end

  def player_phase
    sleep SLEEP_SECOND

    decide = "Hit"
    while decide == "Hit"
      decide = @table.player.decide_action
      if decide == "Hit"
        @table.deal_out_card(@table.player)
        break if @table.player.state == "bust"
      end
      sleep SLEEP_SECOND
    end

    if @table.player.state == "bust"
      "attribute"
    end

    "dealer"
  end

  def dealer_phase
    dealer = @table.dealer

    dealer.show_second_card
    sleep SLEEP_SECOND

    decide = "Hit"
    while decide == "Hit"
      dealer.put_score
      decide = dealer.decide_action
      if decide == "Hit"
        @table.deal_out_card(dealer)
        break if dealer.state == "bust"
      end
      sleep SLEEP_SECOND
    end

    "attribute"
  end
end

# blackjack = Blackjack.new
# blackjack.handle_game_flow("initial")
