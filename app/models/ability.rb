class Ability
  include CanCan::Ability

  def initialize(user)
    user.roles.each do |role|
      send("#{role}_rules") if respond_to?("#{role}_rules")
    end
  end

  def admin_rules
    can :manage, :all
    can :assign_roles, User
  end

  def seller_rules
    can :create, :all
    can :update, :all
    can :destroy, :all
    can :edit_profile, User
    can :update_profile, User
  end
end
