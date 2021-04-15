class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone_number, :date_of_birth, presence: true
  validates :email, uniqueness: { case_sensitive: false }, presence: true

  has_one_attached :profile_picture

  has_one :primary_cr_data, -> { where(primary: true) }, class_name: 'CrAccessData'

  has_many :cr_groups, dependent: :destroy
  has_many :cr_data_users, dependent: :destroy
  has_many :cr_access_data, dependent: :destroy, class_name: 'CrAccessData'
  has_many :accessible_cr_data, class_name: 'CrAccessData', through: :cr_data_users, source: :cr_access_data
  has_many :secondary_cr_data, -> { where(primary: false) }, class_name: 'CrAccessData'
  has_many :primary_groups, through: :primary_cr_data, class_name: 'CrGroup', source: :cr_groups
  has_many :secondary_groups, through: :secondary_cr_data, class_name: 'CrGroup', source: :cr_groups

  validates :profile_picture, blob: { content_type: %w[image/jpg image/jpeg image/png], size_range: 1..3.megabytes }

  accepts_nested_attributes_for :cr_access_data, allow_destroy: true

  def vaccinated?
    cr_access_data.any?(&:fully_vaccinated?)
  end

  def reset_primary_data(cr_access_id)
    data = cr_access_data.find_by(id: cr_access_id)
    return false if data.blank?

    cr_access_data.each do |cr_access|
      cr_access.update(primary: false) unless cr_access.id == cr_access_id
    end
  end

  def accept_info(token)
    data = CrAccessData.decoded_data(token)
    return false unless self.id == data['user_id']

    accessible_cr_data << CrAccessData.where(id: data['cr_access_id'] - accessible_cr_data.ids)
  end

  def unlink_cr_access(id)
    cr_data_users.where(cr_access_data_id: id).destroy_all
  end

  def full_name
    [first_name, middle_name, last_name].reject(&:blank?).join(' ')
  end
end
