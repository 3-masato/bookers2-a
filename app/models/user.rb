class User < ApplicationRecord
  include Searchable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # belongs_to :books
  has_one_attached :profile_image

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  has_many :followings, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :messages, dependent: :destroy
  has_many :entries, dependent: :destroy

  has_many :view_counts, dependent: :destroy

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }

  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  def follow(user)
    unless following?(user)
      active_relationships.create(followed_id: user.id)
    end
  end

  def unfollow(user)
    if following?(user)
      active_relationships.find_by(followed_id: user.id).destroy
    end
  end

  def following?(user)
    followings.include?(user)
  end

  def chat(other_user)
    self_user_entry = Entry.where(user_id: self.id)
    other_user_entry = Entry.where(user_id: other_user.id)

    current_room_id = find_common_room_id(self_user_entry, other_user_entry)

    if current_room_id
      { room_id: current_room_id }
    else
      {
        room: Room.new,
        entry: Entry.new
      }
    end
  end

  private

  # Finds the common room ID shared between two users based on their entries.
  # If no common room exists, returns nil.
  #
  # @param user_a_entries [Entry] Entries related to the first user.
  # @param user_b_entries [Entry] Entries related to the second user.
  #
  # @return [Integer, nil] Returns the ID of the common room if found, otherwise nil.
  def find_common_room_id(user_a_entries, user_b_entries)
    user_a_entries.pluck(:room_id).each do |a_room_id|
      return a_room_id if user_b_entries.exists?(room_id: a_room_id)
    end

    nil
  end
end

