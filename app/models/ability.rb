class Ability
  include CanCan::Ability



  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #

    ## TODO: What we want to do is that anyone can make changes, but they will be flagged as Suggested until approved by admin.
    ##       Admin changes are automatically approved and applied.
       user ||= User.new # guest user (not logged in)
       if user.role == "super_admin"                       # old #  if user.admin?
         can :manage, :all
       elsif user.role == "admin"                       # old #  if user.admin?
         can :manage, :all
       else
         can :manage, :all
         cannot :index, User
         #can [:show, :create, :update, :destroy], #[Event, Act, Embed, Occurrence, Recurrence, Pi
       end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
