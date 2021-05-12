class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone_number, :date_of_birth, presence: true
  validates :email, uniqueness: { case_sensitive: false }, presence: true

  has_one_attached :profile_picture

  has_one :primary_data, -> { where(primary: true) }, class_name: 'CrDataUser'
  has_one :primary_cr_data, through: :primary_data, class_name: 'CrAccessData', source: :cr_access_data

  has_many :cr_groups, dependent: :destroy
  has_many :cr_data_users, dependent: :destroy
  has_many :all_cr_data, through: :cr_data_users, source: :cr_access_data
  has_many :accepted_data_users, -> { where(data_type: CrDataUser::DATA_TYPES[:prepmod]).or(where(status: CrDataUser::STATUSES[:accepted])) }, class_name: 'CrDataUser'
  has_many :accepted_data, through: :accepted_data_users, source: :cr_access_data
  has_many :prepmod_data_users, -> { prepmod }, class_name: 'CrDataUser'
  has_many :invited_data_users, -> { invited }, class_name: 'CrDataUser'
  has_many :cr_access_data, dependent: :destroy, through: :prepmod_data_users
  has_many :accessible_cr_data, class_name: 'CrAccessData', through: :invited_data_users, source: :cr_access_data
  has_many :primary_groups, through: :primary_cr_data, class_name: 'CrGroup', source: :accepted_cr_groups
  has_many :vaccination_records, through: :primary_cr_data, class_name: 'VaccinationRecord'

  validates :profile_picture, blob: { content_type: %w[image/jpg image/jpeg image/png], size_range: 1..3.megabytes }

  accepts_nested_attributes_for :cr_access_data, allow_destroy: true

  def vaccinated?
    cr_access_data.any?(&:fully_vaccinated?)
  end

  def reset_primary_data(cr_data_id)
    data = cr_data_users.find_by(id: cr_data_id)
    return false if data.blank? || data.invited?

    cr_data_users.each do |data_user|
      data_user.update(primary: false) unless data_user.id == cr_data_id
    end
  end

  def accept_info(token)
    data = CrDataUser.decoded_data(token)
    return false unless id == data['user_id']

    CrDataUser.where(id: data['cr_data_user_ids']).update(status: CrDataUser::STATUSES[:accepted])
  end

  def unlink_cr_access(id)
    cr_data_users.where(cr_access_data_id: id).destroy_all
  end

  def full_name
    [first_name, middle_name, last_name].reject(&:blank?).join(' ')
  end

  def self.find_by_invitation_params(params)
    return find_by_email(params[:data]) if params[:type] == EMAIL

    find_by_phone_number(params[:data])
  end
end
