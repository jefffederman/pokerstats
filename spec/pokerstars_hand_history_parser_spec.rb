# coding: utf-8
require 'rubygems'
require 'active_support'
require 'bigdecimal'
require 'bigdecimal/util'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/pokerstats/hand_history')
require File.expand_path(File.dirname(__FILE__) + '/../lib/pokerstats/hand_statistics')
require File.expand_path(File.dirname(__FILE__) + '/../lib/pokerstats/pokerstars_file')
require File.expand_path(File.dirname(__FILE__) + '/../lib/pokerstats/pokerstars_hand_history_parser')
include Pokerstats
include HandConstants


describe PokerstarsTimeStringConverter do
    context "when first created" do
        it "should not reject valid pokerstars time strings" do
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 UTC")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 PT")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 MT")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 CT")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 ET")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 AT")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 BRT")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 WET")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 CET")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 EET")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 MSK")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 CCT")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 JST")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 AWST")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 ACST")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 AEST")}.should_not raise_error
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 NZT")}.should_not raise_error
        end
        
        it "should reject invalid pokerstars time strings" do
            lambda {PokerstarsTimeStringConverter.new("2008/10/31 17:25:42 XX")}.should raise_error(ArgumentError)
        end
    end
    
    context "when converting a pokerstars time string string" do
        it "returns the correct utc dateime for eastern daylight time" do
            PokerstarsTimeStringConverter.new("2008/7/30 17:25:42 ET").as_utc_datetime.should == DateTime.parse("2008/7/30 17:25:42 EDT")
        end
        
        it "returns the correct utc result for eastern standard time" do
            PokerstarsTimeStringConverter.new("2008/01/30 17:25:42 ET").as_utc_datetime.should == DateTime.parse("2008/01/30 17:25:42 EST")
        end
    end
end

describe PokerstarsHandHistoryParser, "recognizes valid hand history" do
  it "should recognize a valid tournament hand history" do
    first_line = "PokerStars Game #21650436825: Tournament #117620218, $10+$1 Hold'em No Limit - Level I (10/20) - 2008/10/31 17:25:42 ET"
    PokerstarsHandHistoryParser.game(first_line).should == "PS21650436825"
  end

  it "should recognize a valid tournament hand history" do
    first_line = "PokerStars Game #33566683789: Tournament #199550385, $10+$1 USD Hold'em No Limit - Level XVIII (2000/4000) - 2009/10/02 22:00:29 ET"
    PokerstarsHandHistoryParser.game(first_line).should == "PS33566683789"
  end
  
  it "should recognize a valid cash game hand history" do
    first_line = "PokerStars Game #21650146783:  Hold'em No Limit ($0.25/$0.50) - 2008/10/31 17:14:44 ET"
    PokerstarsHandHistoryParser.game(first_line).should == "PS21650146783"
  end
  it "should reject an invalid hand history" do
    PokerstarsHandHistoryParser.game("an invalid hand history").should raise_error
  end
end

describe PokerstarsHandHistoryParser, "when parsing structural matter" do
  before :each do
    @stats = HandStatistics.new
    @parser = PokerstarsHandHistoryParser.new(@stats)
  end
  
  context "for tournaments" do
      before(:each) do
        @valid_tournament_headers = [
            @old_style_tournament_header = "PokerStars Game #21650436825: Tournament #117620218, $10+$1 Hold'em No Limit - Level I (10/20) - 2008/10/31 17:25:42 ET",
            @new_style_tournament_header = "PokerStars Game #33566683789: Tournament #199550385, $10+$1 USD Hold'em No Limit - Level XVIII (2000/4000) - 2009/10/02 22:00:29 ET",
            @pot_limit_tournament_header = "PokerStars Game #33566683789: Tournament #199550385, $10+$1 USD Hold'em Pot Limit - Level XVIII (2000/4000) - 2009/10/02 22:00:29 ET",
            @limit_tournament_header = "PokerStars Game #33566683789: Tournament #199550385, $10+$1 USD Hold'em Limit - Level XVIII (2000/4000) - 2009/10/02 22:00:29 ET",
            @freeroll_tournament_header = "PokerStars Game #24703545200: Tournament #137653257, Freeroll  Hold'em No Limit - Level I (10/20) - 2009/02/07 19:24:12 ET",
            @fpp_tournament_header = "PokerStars Game #27572086902: Tournament #158153393, 5125FPP Hold'em No Limit - Level I (10/20) - 2009/04/27 22:19:46 ET"
        ]
      end
   
      it "should parse an old style tournament header" do
        @stats.should_receive(:update_hand).with(
          :name => "PS21650436825",
          :description => "117620218, $10+$1 Hold'em No Limit",
          :ante => "0.0".to_d,
          :table_name => "",
          :max_players => 0,
          :number_players => 0,
          :sb => "10".to_d,
          :bb => "20".to_d,
          :played_at => DateTime.parse("2008/10/31 17:25:42 EDT"),
          :tournament => "117620218",
          :street => :prelude,
          :board => "",
          :game_type => "Hold'em",
          :stakes_type => "10".to_d,
          :limit_type => "No Limit"
        )
        @parser.parse(@old_style_tournament_header)
      end
  
    it "should recognize a new style tournament hand history" do
      @stats.should_receive(:update_hand).with(
          :name => "PS33566683789",
          :description => "199550385, $10+$1 USD Hold'em No Limit", 
          :ante => "0.0".to_d,
          :table_name => "",
          :max_players => 0,
          :number_players => 0,
          :sb => "2000".to_d,
          :bb => "4000".to_d,
          :played_at => DateTime.parse("2009/10/03 02:00:29 UDT"),
          :tournament => "199550385",
          :street => :prelude,
          :board => "",
          :game_type => "Hold'em",
          :stakes_type => "10".to_d,
          :limit_type => "No Limit"
      )
      @parser.parse(@new_style_tournament_header)
    end
  
    it "should recognize a limit tournament hand history" do
      @stats.should_receive(:update_hand).with(
          :name => "PS33566683789",
          :description => "199550385, $10+$1 USD Hold'em Limit", 
          :ante => "0.0".to_d,
          :table_name => "",
          :max_players => 0,
          :number_players => 0,
          :sb => "2000".to_d,
          :bb => "4000".to_d,
          :played_at => DateTime.parse("2009/10/03 02:00:29 UDT"),
          :tournament => "199550385",
          :street => :prelude,
          :board => "",
          :game_type => "Hold'em",
          :stakes_type => "10".to_d,
          :limit_type => "Limit"
      )
      @parser.parse(@limit_tournament_header)
    end
  
    it "should recognize a pot limit tournament hand history" do
      @stats.should_receive(:update_hand).with(
          :name => "PS33566683789",
          :description => "199550385, $10+$1 USD Hold'em Pot Limit", 
          :ante => "0.0".to_d,
          :table_name => "",
          :max_players => 0,
          :number_players => 0,
          :sb => "2000".to_d,
          :bb => "4000".to_d,
          :played_at => DateTime.parse("2009/10/03 02:00:29 UDT"),
          :tournament => "199550385",
          :street => :prelude,
          :board => "",
          :game_type => "Hold'em",
          :stakes_type => "10".to_d,
          :limit_type => "Pot Limit"
      )
      @parser.parse(@pot_limit_tournament_header)
    end
  
      it "should recognize a freeroll tournament hand history" do
        @stats.should_receive(:update_hand).with(
            :name => "PS24703545200",
            :description => "137653257, Freeroll Hold'em No Limit",
            :ante => "0.0".to_d,
            :table_name => "",
            :max_players => 0,
            :number_players => 0,
            :sb => "10".to_d,
            :bb => "20".to_d,
            :played_at => DateTime.parse("Sun, 08 Feb 2009 00:24:12 +0000"),
            :tournament => "137653257",
            :street => :prelude,
            :board => "",
            :game_type => "Hold'em",
            :stakes_type => "0".to_d,
            :limit_type => "No Limit"
        )
        @parser.parse(@freeroll_tournament_header)
      end
 
      it "should recognize a tournament hand history paid for with FPP" do
        @stats.should_receive(:update_hand).with(
            :name => "PS27572086902",
            :description => "158153393, 5125FPP Hold'em No Limit",
            :ante => "0.0".to_d,
            :table_name => "",
            :max_players => 0,
            :number_players => 0,
            :sb => "10".to_d,
            :bb => "20".to_d,
            :played_at => DateTime.parse("2009/04/27 22:19:46 EDT"),
            :tournament => "158153393",
            :street => :prelude,
            :board => "",
            :game_type => "Hold'em",
            :stakes_type => "0".to_d,
            :limit_type => "No Limit"
        )  
        @parser.parse(@fpp_tournament_header)
      end
  
      it "should recognize a tournament header" do
        @valid_tournament_headers.each do |header|
            PokerstarsHandHistoryParser.should have_valid_header(header)
        end
        PokerstarsHandHistoryParser.should have_valid_header("PokerStars Game #21650436825: Tournament #117620218, $10+$1 Hold'em No Limit - Level I (10/20) - 2008/10/31 17:25:42 ET\nsnuggles\n")
      end
  end
  
  context "for cash games" do
      before(:each) do
        @valid_cash_game_headers = [
            @no_limit_cash_game_header = "PokerStars Game #21650146783:  Hold'em No Limit ($0.25/$0.50) - 2008/10/31 17:14:44 ET",
            @pot_limit_cash_game_header = "PokerStars Game #21650146783:  Hold'em Pot Limit ($0.25/$0.50) - 2008/10/31 17:14:44 ET",
            @limit_cash_game_header = "PokerStars Game #21650146783:  Hold'em Limit ($0.25/$0.50) - 2008/10/31 17:14:44 ET"
        ]
      end
  
      it "should parse a cash game no limit header" do
        @stats.should_receive(:update_hand).with(
          :name => 'PS21650146783',
          :description => "Hold'em No Limit ($0.25/$0.50)",
          :ante => "0.00".to_d,
          :table_name => "",
          :max_players => 0,
          :number_players => 0,
          :sb => "0.25".to_d, 
          :bb => "0.50".to_d,
          :played_at => DateTime.parse("2008/10/31 17:14:44 EDT"),
          :tournament => nil,
          :street => :prelude,
          :board => "", # due to pokerstars hand history bug
          :game_type => "Hold'em",
          :stakes_type => "0.5".to_d,
          :limit_type => "No Limit"
        )
        @parser.parse(@no_limit_cash_game_header)
      end
  
      it "should recognize cash game pot limit header" do
          @stats.should_receive(:update_hand).with(
            :name => 'PS21650146783',
            :description => "Hold'em Pot Limit ($0.25/$0.50)",
            :ante => "0.00".to_d,
            :table_name => "",
            :max_players => 0,
            :number_players => 0,
            :sb => "0.25".to_d, 
            :bb => "0.50".to_d,
            :played_at => DateTime.parse("2008/10/31 17:14:44 EDT"),
            :tournament => nil,
            :street => :prelude,
            :board => "", # due to pokerstars hand history bug
            :game_type => "Hold'em",
            :stakes_type => "0.5".to_d,
            :limit_type => "Pot Limit"
          )
          @parser.parse(@pot_limit_cash_game_header)
      end
  
      it "should recognize cash game limit header" do
          @stats.should_receive(:update_hand).with(
            :name => 'PS21650146783',
            :description => "Hold'em Limit ($0.25/$0.50)",
            :ante => "0.00".to_d,
            :table_name => "",
            :max_players => 0,
            :number_players => 0,
            :sb => "0.25".to_d, 
            :bb => "0.50".to_d,
            :played_at => DateTime.parse("2008/10/31 17:14:44 EDT"),
            :tournament => nil,
            :street => :prelude,
            :board => "", # due to pokerstars hand history bug
            :game_type => "Hold'em",
            :stakes_type => "0.5".to_d,
            :limit_type => "Limit"
          )
          @parser.parse(@limit_cash_game_header)
      end
  
      it "should recognize all cash game headers" do
          @valid_cash_game_headers.each do |header|
              PokerstarsHandHistoryParser.should have_valid_header(header)
          end
      end
  
      it "should not recognize an invalid header" do
        PokerstarsHandHistoryParser.should_not have_valid_header("I will love you to the end of the earth\nNow and Forever\nEver Always,\nYour Andrew")
      end
  end
  
  it "should parse a hole card header" do
    @stats.should_receive(:update_hand).with(:street => :preflop)
    @parser.parse("*** HOLE CARDS ***")
  end
  
  it "should parse a flop header" do
    @stats.should_receive(:update_hand).with(:street => :flop)
    @parser.parse("*** FLOP *** [5c 2d Jh]")
  end
  
  it "should parse a turn header" do
    @stats.should_receive(:update_hand).with(:street => :turn)
    @parser.parse("*** TURN *** [5c 2d Jh] [4c]")
  end
  
  it "should parse a river header" do
    @stats.should_receive(:update_hand).with(:street => :river)
    @parser.parse("*** RIVER *** [5c 2d Jh 4c] [5h]")
  end
  
  it "should parse a showdown header" do
    @stats.should_receive(:update_hand).with(:street => :showdown)
    @parser.parse("*** SHOW DOWN *** [5c 2d Jh 4c] [5h]")
  end
  
  it "should parse a summary header" do
    @stats.should_receive(:update_hand).with(:street => :summary)
    @parser.parse("*** SUMMARY *** [5c 2d Jh 4c] [5h]")
  end
  
  it "should parse a 'dealt to' header" do
    @stats.should_receive(:register_action).with('wizardwerdna', 'dealt', :result => :cards, :data => "2s Th")
    @parser.parse("Dealt to wizardwerdna [2s Th]")
  end
  
  it "should parse a 'Total pot' card header" do
    @stats.should_receive(:update_hand).with(:total_pot => "10.75".to_d, :rake => "0.50".to_d)
    @parser.parse("Total pot $10.75 | Rake $0.50")
  end
  
  it "should parse a board header" do
    @stats.should_receive(:update_hand).with(:board => "5c 2d Jh 4c 5h")
    @parser.parse("Board [5c 2d Jh 4c 5h]")
  end
end


describe PokerstarsHandHistoryParser, "when parsing prelude matter" do
  before :each do
    @stats = HandStatistics.new
    @parser = PokerstarsHandHistoryParser.new(@stats)
  end

  it "should parse a tournament button line" do
    @stats.should_receive(:register_button).with(6)
    @stats.should_receive(:update_hand).with(:max_players => 9, :table_name => '117620218 1')
    @parser.parse("Table '117620218 1' 9-max Seat #6 is the button")
  end

  it "should parse a cash game button line" do
    @stats.should_receive(:register_button).with(2)
    @stats.should_receive(:update_hand).with(:max_players => 6, :table_name => 'Charybdis IV')
    @parser.parse("Table 'Charybdis IV' 6-max Seat #2 is the button")
  end

  it "should parse a player line" do
    @stats.should_receive(:register_player).with(:screen_name => 'BadBeat_Brat', :seat => 3, :starting_stack => "1500".to_d)
    @parser.parse("Seat 3: BadBeat_Brat (1500 in chips)")
  end

  it "should parse a player line with accents" do
    @stats.should_receive(:register_player).with(:screen_name => 'Gwünni', :seat => 8, :starting_stack => "3000".to_d)
    @parser.parse("Seat 8: Gwünni (3000 in chips)")
  end

  it "should parse a small blind header and register the corresponding action" do
    @stats.should_receive(:register_action).with("Hoggsnake", 'posts', :result => :post, :amount => "10".to_d)
    @parser.parse("Hoggsnake: posts small blind 10")
  end

  it "should parse a big blind header and register the corresponding action" do
    @stats.should_receive(:register_action).with("BadBeat_Brat", 'posts', :result => :post, :amount => "20".to_d)
    @parser.parse("BadBeat_Brat: posts big blind 20")
  end

  it "should parse an ante header and register the corresponding action, :updating the :ante field as well when ante is larger" do
    @stats.update_hand(:ante=>0)
    @stats.should_receive(:register_action).with("BadBeat_Brat", 'antes', :result => :post, :amount => "15".to_d)
    @stats.should_receive(:update_hand).with(:ante => "15".to_d)
    @parser.parse("BadBeat_Brat: posts the ante 15")
  end

  it "should parse an ante header and register the corresponding action, :updating the :ante field as well when ante is not larger" do
    @stats.update_hand(:ante=>20)
    @stats.should_receive(:register_action).with("BadBeat_Brat", 'antes', :result => :post, :amount => "15".to_d)
    @stats.should_receive(:update_hand).with(:ante => "20".to_d)
    @parser.parse("BadBeat_Brat: posts the ante 15")
  end
end

describe PokerstarsHandHistoryParser, "when parsing poker actions" do
  before :each do
    @stats = HandStatistics.new
    @parser = PokerstarsHandHistoryParser.new(@stats)
  end
  
  it "should properly parse and register a fold" do
    @stats.should_receive(:register_action).with("Gwünni", "folds", :result => :neutral)
    @parser.parse("Gwünni: folds")
  end
  it "should properly parse and register a check" do
    @stats.should_receive(:register_action).with("billy", "checks", :result => :neutral)
    @parser.parse("billy: checks")
  end
  it "should properly parse and register a call" do
    @stats.should_receive(:register_action).with("billy", "calls", :result => :pay, :amount => "1.25".to_d)
    @parser.parse("billy: calls $1.25")
  end
  it "should properly parse and register a bet" do
    @stats.should_receive(:register_action).with("billy", "bets", :result => :pay, :amount => "1.20".to_d)
    @parser.parse("billy: bets $1.20")
  end
  it "should properly parse and register a raise" do
    @stats.should_receive(:register_action).with("billy", "raises", :result => :pay_to, :amount => "1.23".to_d)
    @parser.parse("billy: raises $1 to $1.23")
  end
  it "should properly parse and register a return" do
    @stats.should_receive(:register_action).with("billy", "return", :result => :win, :amount => "1.50".to_d)
    @parser.parse("Uncalled bet ($1.50) returned to billy")
  end
  it "should properly parse and register a collection" do
    @stats.should_receive(:register_action).with("billy", "wins", :result => :win, :amount => "1.90".to_d)
    @parser.parse("billy collected $1.90 from pot")
  end
  it "should properly parse and register a muck" do
    @stats.should_receive(:register_action).with("billy", "mucks", :result => :neutral)
    @parser.parse("billy: mucks hand")
  end
end