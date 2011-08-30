# s: 3R / 8HP
# S: 5R / 12HP
# a: 2R / 3HP / R3 => 9HP

class Player
  attr_accessor :warrior
  attr_accessor :body
  
  def initialize
    @body = {
      :health => [nil, 20],
      :direction => :backward
    }
  end
  
  def self_check(warrior)
    @warrior = warrior
    body[:health][0] = body[:health][1]
    body[:health][1] = warrior.health
  end
  
  def health_enough?
    body[:health][1] > 12
  end
  
  def safe_position?
    body[:health][1] >= body[:health][0]
  end
  
  def encountered_wall!
    if warrior.feel(body[:direction]).wall?
      body[:direction] = Direction.opposite_of(body[:direction])
      warrior.walk!(body[:direction])
      return true
    end
    
    return false
  end
  
  def encountered_captive!
    if warrior.feel(body[:direction]).captive?
      warrior.rescue!(body[:direction])
      return true
    end
    
    return false
  end
  
  def fight!
    @fight_state ||= :moving
    
    case @fight_state
    when :moving
      if warrior.feel(body[:direction]).empty?
        warrior.walk!(body[:direction])
      else
        warrior.attack!(body[:direction])
        @fight_state = :attacking
      end
      return true
    when :attacking
      if warrior.feel(body[:direction]).empty?
        warrior.walk!(Direction.opposite_of(body[:direction]))
        @fight_state = :resting
      else
        warrior.attack!(body[:direction])
      end
      return true
    when :resting
      if body[:health][1] < 20
        safe_position? ? warrior.rest! : warrior.walk!(Direction.opposite_of(body[:direction]))
      else
        warrior.walk!(body[:direction])
        @fight_state = :moving
      end
      return true
    end
    
    return false
  end
  
  def play_turn(warrior)
    self_check(warrior)
    
    return if encountered_wall!
    return if encountered_captive!
    return if fight!
  end
end

module Direction
  VALUES = [:forward, :right, :backward, :left]
  
  class << self
    def opposite_of(direction)
      VALUES[(VALUES.index(direction) + 2) % 4]
    end
  end
end