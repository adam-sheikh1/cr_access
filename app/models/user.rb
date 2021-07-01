class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone_number, :date_of_birth, presence: true
  validates :email, uniqueness: { case_sensitive: false }, presence: true

  has_one :primary_data, -> { where(primary: true) }, class_name: 'CrDataUser'
  has_one :primary_cr_data, through: :primary_data, class_name: 'CrAccessData', source: :cr_access_data

  has_many :cr_groups, dependent: :destroy
  has_many :cr_data_users, dependent: :destroy
  has_many :all_cr_data, through: :cr_data_users, source: :cr_access_data
  has_many :accepted_data_users, lambda {
    where(data_type: CrDataUser::DATA_TYPES[:prepmod]).or(where(status: CrDataUser::STATUSES[:accepted]))
  }, class_name: 'CrDataUser'
  has_many :accepted_data, through: :accepted_data_users, source: :cr_access_data
  has_many :prepmod_data_users, -> { prepmod }, class_name: 'CrDataUser'
  has_many :invited_data_users, -> { invited }, class_name: 'CrDataUser'
  has_many :cr_access_data, dependent: :destroy, through: :prepmod_data_users
  has_many :accessible_cr_data, class_name: 'CrAccessData', through: :invited_data_users, source: :cr_access_data
  has_many :primary_groups, through: :primary_cr_data, class_name: 'CrGroup', source: :accepted_cr_groups
  has_many :owned_vaccinations, through: :all_cr_data, source: :vaccination_records
  has_many :vaccination_users, dependent: :destroy
  has_many :accessible_vaccinations, through: :vaccination_users, source: :vaccination_record
  has_many :shared_cr_data, through: :accessible_vaccinations, source: :cr_access_data
  has_many :accepted_cr_groups, -> { accepted }, through: :all_cr_data, source: :cr_access_groups
  has_many :owned_cr_groups, through: :cr_groups, source: :cr_access_groups
  has_many :share_requests, dependent: :destroy
  has_many :incoming_requests, class_name: 'ShareRequest', foreign_key: :recipient_id

  accepts_nested_attributes_for :cr_access_data, allow_destroy: true
  accepts_nested_attributes_for :share_requests, allow_destroy: true

  TWO_FA_FREQUENCY = 5

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

  def generate_2fa(resend: false)
    return false if !resend && two_fa_code.present? && last_2fa_interval < TWO_FA_FREQUENCY + 1

    update_columns(two_fa_code: random_code, two_fa_sent_at: Time.now)
    UserMailer.send_2fa_mail(id).deliver_later
    true
  end

  def last_2fa_interval
    ((Time.now - two_fa_sent_at) / 1.minute).ceil
  end

  def verify_2fa(code)
    two_fa_code == code
  end

  def increment_invites_sent
    increment!(:total_invites_sent, 1)
    reset_invites_sent if invites_sent_at != Date.today
  end

  def reset_invites_sent
    update_columns(invites_sent_at: Date.today, total_invites_sent: 0)
  end

  def invites_sent_today
    reset_invites_sent if invites_sent_at != Date.today

    total_invites_sent
  end

  def vaccination_records
    return [] if primary_cr_data.blank?

    primary_cr_data.vaccination_records_accessor(reload: true)
  end

  def shared_data_accessor
    data = shared_cr_data.distinct.to_a
    FetchPatientData.assign_cr_data_attributes(data)
    data
  end

  private

  def random_code
    SecureRandom.alphanumeric(8).upcase
  end
end
