class TimeTracking::TimeSheet < ActiveRecord::Base
  include HumanizeName
  include Abstractable
  belongs_to :owner, polymorphic: true
  belongs_to :user

  validates :name, :presence => true

  has_many :ownerships, :as => :owner, :dependent => :destroy, :class_name => 'Ownership'
  has_many :timers, :through => :ownerships, :source => :item, :source_type => 'TimeTracking::Timer'

  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :scoped, :finders], :scope => :owner

  def slug_candidates
    [
      :name
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end
end
