# s: 3R / 8HP
# S: 5R / 12HP
# a: 2R / 3HP / R3 => 9HP

class Player
  attr_accessor :warrior
  attr_accessor :body
  
  def initialize
    @state = :moving
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
    body[:direction] = Direction.opposite_of(body[:direction])
    warrior.walk!(body[:direction])
  end
  
  def play_turn(warrior)
    self_check(warrior)
    
    if warrior.feel(body[:direction]).wall?
      encountered_wall!
    elsif warrior.feel(body[:direction]).captive?
      warrior.rescue!(body[:direction])
    else
      
      case @state
      when :moving
        if warrior.feel(body[:direction]).enemy?
          warrior.attack!(body[:direction])
          @state = :attacking
        else
          warrior.walk!(body[:direction])
        end
      when :attacking
        if warrior.feel(body[:direction]).enemy?
          warrior.attack!(body[:direction])
        else
          warrior.walk!(Direction.opposite_of(body[:direction]))
          @state = :resting
        end
      when :resting
        if body[:health][1] < 20
          safe_position? ? warrior.rest! : warrior.walk!(Direction.opposite_of(body[:direction]))
        else
          warrior.walk!(body[:direction])
          @state = :moving
        end
      end
    end
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