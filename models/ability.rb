class Ability
  require 'cancan'
  include CanCan::Ability
  def initialize(user)
    @user = user
  end
end