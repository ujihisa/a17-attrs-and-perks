require 'sinatra'

ALL_PERKS = {
  PER: ['Gunslinger', 'Shotgun Messiah', 'Automatic Weapons', 'Dead Eye', 'Archery', 'Explosive Weapons', 'Boom! Headshot!', 'Run And Gun', 'Lucky Looter', 'Salvage Operations'],
  STR: ['Wrecking Crew', 'Sexual Tyrannosaurus', 'Flurry of Blows', 'Deep Cuts', 'Stay Down!', 'Heavy Metal', 'Skull Crusher', 'Miner 69\'er', 'Pack Mule', 'Mother Lode'],
  FRT: ['Heavy Armor', 'The Huntsman', 'Intrinsic Immunity', 'Well Insulated', 'Living Off The Land', 'Pain Tolerance', 'Healing Factor', 'Fully Hydrated', 'Slow Metabolism', 'Self Medicated'],
  AGI: ['Rule 1: Cardio', 'Light Armor', 'Charging Bull', 'Parkour', 'Olympic Swimmer', 'Ninja Movement', 'Hidden Strike', 'From Shadows'],
  INT: ['Better Barter', 'The Daring Adventurer', 'Charismatic Nature', 'Hammer & Forge', 'Grease Monkey', 'Advanced Engineering', 'Yeah, Science!', 'Physician', 'Master Chef']
}

PERK_DETAILS = {
  'Gunslinger' => {
    '攻撃力': ['+0%', '+5%', '+10%', '+15%', '+20%', '+25%'],
    'リロード速度': ['+0%', '+10%', '+15%', '+20%', '+25%', '+30%'],
    'クリティカル': ['-', '-', '-', '5発', '4発', '3発'],
  },
  'Shotgun Messiah' => {
    '攻撃力': ['+0%', '+15%', '+20%', '+25%', '+30%', '+35%'],
    'リロード速度': ['+0%', '+10%', '+15%', '+20%', '+25%', '+30%'],
    'スタン率': ['-', '-', '-', '50%', '75%', '100%'],
    'スタン時間': ['-', '-', '-', '4秒', '6秒', '6秒'],
    '足破壊率': ['-', '-', '-', '-', '-', '100%'],
  },
  'Automatic Weapons' => {
    '攻撃力': ['+0.0%', '+5%', '+10%', '+15%', '+20%', '+25%'],
    'リロード速度': ['+0%', '+10%', '+15%', '+20%', '+25%', '+30%'],
    '反動距離(水平)': ['-0%', '-5%', '-11.66%', '-18.33%', '-25%', '-0%'],
    '反動距離(垂直)': ['-0%', '-5%', '-10%', '-15%', '-20%', '-25%'],
    'スタミナ回復': ['-', '-', '-', '+5', '+7', '+10'],
  },
  'Dead Eye' => {
    '攻撃力': ['+0.0%', '+5.0%', '+7.5%', '+10.0%', '+12.5%', '+15.0%'],
    'リロード速度': ['+0.0%', '+10.0%', '+10.0%', '+16.6%', '+23.3%', '+30.0%'],
    '照準速度': ['+0%', '+10%', '+15%', '+20%', '+25%', '+30%'],
    'エイム中のスタミナ回復速度': ['-', '-', '-', '+10%', '+20%', '+30%'],
    'キルストリーク': ['-', '-', '-', '+10% +20% +30%', '+20% +30% +40%', '+30% +40% +50%'],
  },
  'Archery' => {
    'リロード速度': ['+0%', '+10%', '+15%', '+25%', '+35%', '+50%'],
    'ドロー速度': ['+0%', '+10%', '+15%', '+25%', '+35%', '+50%'],
    '照準速度': ['+0%', '+10%', '+20%', '+30%', '+40%', '+50%'],
    'スタン率': ['-', '-', '-', '50%', '75%', '100%'],
    'スタン時間': ['-', '-', '-', '4秒', '6秒', '6秒'],
    '足破壊率': ['-', '-', '-', '-', '-', '100%'],
  },
  'Explosive Weapons' => {
    'リロード速度': ['+0%', '+15%', '+20%', '+25%', '+30%', '+35%'],
    '照準速度': ['+0%', '+10%', '+20%', '+30%', '+40%', '+50%'],
    '攻撃力減衰距離': ['+0.0%', '+20.0%', '+27.5%', '+35.0%', '+42.5%', '+50.0%'],
    '射程距離': ['-', '-', '-', '+15%', '+20%', '+25%'],
    '発射速度': ['-', '-', '-', '+10%', '+15%', '+20%'],
  },
  'Boom! Headshot!' => {
    '攻撃力': ['+0%', '+20%', '+40%', '+60%', '+80%', '+100%'],
    '頭破壊率': ['-', '-', '-', '+5%', '+10%', '+15%'],
  },
  'Run And Gun' => {
    '腰だめ撃ちのばらつき距離': ['-', '-5%', '-10%', '-15%', '-20%', '-25%'],
    'リロード中の歩き速度': ['-50%', '-40%', '-30%', '-20%', '-10%', '-0%'],
    'リロード中の走り速度': ['-50%', '-40%', '-30%', '-20%', '-10%', '-0%'],
    'リロード中のジャンプ距離': ['-50%', '-40%', '-30%', '-20%', '-10%', '-0%'],
  },
  'Lucky Looter' => {
    'ルート品質': ['+0', '+50', '+100', '+150', '+200', '+250'],
    'ルート時間': ['-0%', '-10%', '-20%', '-40%', '-60%', '-80%'],
    'トレジャー距離': ['9', '7', '6', '5', '4', '3'],
  },
  'Salvage Operations' => {
    '対物破壊力': ['+0%', '+10%', '+20%', '+30%', '+40%', '+50%'],
    '獲得資材量': ['+0%', '+20%', '+40%', '+60%', '+80%', '+100%'],
  },
}

# Available == !insufficiencies(...)
def insufficiencies(perk, player_attrs, player_level)
  perk_name, perk_level = perk
  case perk_name
  when *ALL_PERKS[:PER]
    player_attrs[:PER] < [0, 1, 3, 5, 7, 10][perk_level] and 'Insufficient PER'
  when *ALL_PERKS[:STR]
    player_attrs[:STR] < [0, 1, 3, 5, 7, 10][perk_level]  and 'Insufficient STR'
  when *ALL_PERKS[:FRT]
    player_attrs[:FRT] < [0, 1, 3, 5, 7, 10][perk_level]  and 'Insufficient FRT'
  when *ALL_PERKS[:AGI]
    player_attrs[:AGI] < [0, 1, 3, 5, 7, 10][perk_level]  and 'Insufficient AGI'
  when 'Better Barter', 'The Daring Adventurer'
    player_attrs[:INT] < [0, 1, 3, 5, 7, 10][perk_level] and 'Insufficient INT'
  when 'Charismatic Nature'
    player_attrs[:INT] < [0, 1, 3, 5, 7][perk_level] and 'Insufficient INT'
  when 'Hammer & Forge'
    (player_attrs[:INT] < [0, 4, 5, 6, 8, 9][perk_level] and 'Insufficient INT') or
      (player_level < [0, 10, 20, 35, 70, 100][perk_level] and 'Insufficient player level')
  when 'Grease Monkey'
    (player_attrs[:INT] < [0, 4, 6, 7, 9, 10][perk_level] and 'Insufficient INT') or
      (player_level < [0, 1, 25, 50, 85, 120][perk_level] and 'Insufficient player level')
  when 'Advanced Engineering'
    (player_attrs[:INT] < [0, 6, 7, 8, 9, 10][perk_level] and 'Insufficient INT') or
      (player_level < [0, 25, 40, 60, 80, 100][perk_level] and 'Insufficient player level')
  when 'Yeah, Science!'
    player_attrs[:INT] < [0, 6, 7, 8, 9, 10][perk_level] and 'Insufficient INT'
  when 'Physician'
    player_attrs[:INT] < [0, 4, 6, 8, 9, 10][perk_level] and 'Insufficient INT'
  when 'Master Chef'
    player_attrs[:INT] < [0, 1, 3, 5, 7, 10][perk_level] and 'Insufficient INT'
  else
    raise ArgumentError, 'No such perk'
  end
end

Player = Struct.new(:level, :skill_point, :attrs, :perks) do
  def level_up(n = 1)
    Player.new(level + n, skill_point + n, attrs, perks)
  end

  # returns one of them
  #   [new_player, nil]
  #   [nil, 'error message']
  def take_attr(attr_name)
    new_attr_level = attrs[attr_name] + 1
    if new_attr_level > 10
      return [nil, "#{attr_name}: Attr level beyond 10"]
    end
    new_skill_point = skill_point - [0, 1, 1, 1, 2, 2, 3, 3, 4, 5][new_attr_level]
    if new_skill_point < 0
      return [nil, "#{attr_name}: Insufficient skill point"]
    end
    [Player.new(level, new_skill_point, attrs.merge(attr_name => new_attr_level), perks), nil]
  end

  # returns one of them
  #   [new_player, nil]
  #   [nil, 'error message']
  def take_perk(perk_name)
    if self.skill_point <= 0
      
      return [nil, "#{perk_name}: Insufficient skill point"]
    end
    perk_level = perks[perk_name] || 0
    x = insufficiencies([perk_name, perk_level], self.attrs, self.level)
    if x
      [nil, x]
    else
      [Player.new(level, skill_point - 1, attrs, perks.merge(perk_name => perk_level + 1)), nil]
    end
  end

  def description
    table = {
      PER: {
        '射撃系武器全般の攻撃力': ['+0%', '+5%', '+10%', '+15%', '+20%', '+25%', '+30%', '+35%', '+40%', '+50%'],
        '弾のバラつき': ['+18%', '+16%', '+14%', '+12%', '+10%', '+8%', '+6%', '+4%', '+2%', '+0%'],
      },
      STR: {
        '近接系武器全般の攻撃力': ['+0%', '+5%', '+10%', '+15%', '+20%', '+25%', '+30%', '+35%', '+40%', '+50%'],
        '対物破壊力': ['+0%', '+5%', '+10%', '+15%', '+20%', '+25%', '+30%', '+35%', '+40%', '+50%'],
      },
      FRT: {
        '最大体力量': ['100', '110', '120', '130', '140', '150', '160', '170', '180', '200'],
        '最大体力の減少のしやすさ': ['+0%', '+3%', '+6%', '+9%', '+12%', '+15%', '+18%', '+21%', '+24%', '+30%'],
        '最大水分量': ['105', '110', '115', '120', '125', '130', '135', '140', '145', '150'],
      },
      AGI: {
        'スタミナ上限最大値': ['100', '110', '120', '130', '140', '150', '160', '170', '180', '200'],
      },
      INT: {
        'クラフト品質': ['1', '2', '2', '3', '3', '4', '4', '5', '5', '6'],
        'クラフト時間': ['-0%', '-10%', '-15%', '-20%', '-25%', '-30%', '-35%', '-40%', '-45%', '-50%'],
      }
    }
    attrs.map {|attr_name, attr_level|
      "#{attr_name}(#{attr_level}): " +
        table[attr_name].map {|k, vs| "#{k}: #{vs[attr_level - 1]}" }.join(', ') +
        "\n" +
        (ALL_PERKS[attr_name] & perks.keys).map {|perk_name|
          header = "  #{perk_name}(#{perks[perk_name]}):"
          body = (PERK_DETAILS[perk_name] || {}).map {|k, vs|
            "    #{k}: #{vs[perks[perk_name] - 1]}"
          }
          header += " (TODO)" if body.empty?
          [header, *body].join("\n")
        }.join("\n")
    }.join("\n")
  end
end

# player = Player.new(1, 4, {PER: 1, STR: 1, FRT: 1, AGI: 1, INT: 1}, {})
# p player
# p player = player&.take_perk('Gunslinger')
# p player = player&.take_perk('Gunslinger')
# p player = player&.take_perk('Skull Crusher')
# p player, _ = player&.take_attr(:PER)
# p player = player&.level_up
# p player, _ = player&.take_attr(:PER)
# p player = player&.level_up
# p player = player&.take_perk('Gunslinger')
# # p player = player&.take_perk('Gunslinger')
# puts player.description


# returns one of them
#   [new_player, nil]
#   [nil, error_message]
def apply_action(action, player)
  case action
  when *ALL_PERKS.keys.map(&:to_s)
    player.take_attr(action.to_sym)
  when *ALL_PERKS.values.flatten
    player.take_perk(action)
  when 'levelup'
    [player.level_up, nil]
  else
    raise NotImplementedError
  end
end

get '/' do
  @player = Player.new(1, 4, {PER: 1, STR: 1, FRT: 1, AGI: 1, INT: 1}, {})
  @history = params.delete(:history)&.scan(/"([^"]+)"/)&.flatten(1) || []
  raise 'Server error' if @history.size > 50
  @history.each do |action|
    # errors shouldn't occur
    player, _ = apply_action(action, @player)
    @player = player if player
  end

  # ignore params besides the first one for now
  action = params.keys.first
  if action
    player, @error = apply_action(action, @player)
    if @error
      # nop
    else
      @player = player
      @history << action
      @flash = "#{action} succeeded."
    end
  end
  haml :index, format: :html5
end
