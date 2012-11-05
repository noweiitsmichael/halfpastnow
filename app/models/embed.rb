class Embed < ActiveRecord::Base
  belongs_to :embedable, :polymorphic => true
end
