class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all if !user.nil?

    user ||= User.new # guest user (not logged in)

    if user.organiser?
      can :manage, :all
    elsif user.overseer?
      can [:review, :do_review], Project
    elsif user.coordinator?
      can [:update, :create], Project
    end

  end
end
