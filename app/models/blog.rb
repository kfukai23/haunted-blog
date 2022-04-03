# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true
  before_save :ensure_eyecatch_used_by_only_premium_user

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where('title LIKE ? OR content LIKE ?', "%#{term}%", "%#{term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end

  private

  # NOTE: 非 premium ユーザに対しては controller で random_eyecatch を受け付けないようにしているが、万一に備える
  def ensure_eyecatch_used_by_only_premium_user
    self.random_eyecatch = false unless user.premium?
  end
end
