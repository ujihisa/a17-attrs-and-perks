require 'sinatra'

ALL_PERKS = {
  PER: ['Gunslinger', 'Shotgun Messiah', 'Automatic Weapons', 'Dead Eye', 'Archery', 'Explosive Weapons', 'Boom! Headshot!', 'Run And Gun', 'Lucky Looter', 'Salvage Operations'],
  STR: ['Wrecking Crew', 'Sexual Tyrannosaurus', 'Flurry of Blows', 'Deep Cuts', 'Stay Down!', 'Heavy Metal', 'Skull Crusher', 'Miner 69\'er', 'Pack Mule', 'Mother Lode'],
  FRT: ['Heavy Armor', 'The Huntsman', 'Intrinsic Immunity', 'Well Insulated', 'Living Off The Land', 'Pain Tolerance', 'Healing Factor', 'Fully Hydrated', 'Slow Metabolism', 'Self Medicated'],
  AGI: ['Rule 1: Cardio', 'Light Armor', 'Charging Bull', 'Parkour', 'Olympic Swimmer', 'Ninja Movement', 'Hidden Strike', 'From Shadows'],
  INT: ['Better Barter', 'The Daring Adventurer', 'Charismatic Nature', 'Hammer & Forge', 'Grease Monkey', 'Advanced Engineering', 'Yeah, Science!', 'Physician', 'Master Chef']
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

  def take_attr(attr_name)
    new_attr_level = attrs[attr_name] + 1
    if new_attr_level > 10
      warn('Attr level beyond 10')
      return nil
    end
    new_skill_point = skill_point - [0, 1, 1, 1, 2, 2, 3, 3, 4, 5][new_attr_level]
    if new_skill_point < 0
      warn('Insufficient skill point')
      return nil
    end
    Player.new(level, new_skill_point, attrs.merge(attr_name => new_attr_level), perks)
  end

  def take_perk(perk_name)
    if self.skill_point <= 0
      warn 'Insufficient skill point'
      return nil
    end
    perk_level = perks[perk_name] || 0
    x = insufficiencies([perk_name, perk_level], self.attrs, self.level)
    if x
      warn(x)
      nil
    else
      Player.new(level, skill_point - 1, attrs, perks.merge(perk_name => perk_level + 1))
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
          "  #{perk_name}(#{perks[perk_name]}): TODO"
        }.join(', ')
    }.join("\n")
  end
end

# player = Player.new(1, 4, {PER: 1, STR: 1, FRT: 1, AGI: 1, INT: 1}, {})
# p player
# p player = player&.take_perk('Gunslinger')
# p player = player&.take_perk('Gunslinger')
# p player = player&.take_perk('Skull Crusher')
# p player = player&.take_attr(:PER)
# p player = player&.level_up
# p player = player&.take_attr(:PER)
# p player = player&.level_up
# p player = player&.take_perk('Gunslinger')
# # p player = player&.take_perk('Gunslinger')
# puts player.description



get '/' do
  @player = Player.new(1, 4, {PER: 1, STR: 1, FRT: 1, AGI: 1, INT: 1}, {})
  haml :index, format: :html5
end
