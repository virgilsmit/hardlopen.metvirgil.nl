class User < ApplicationRecord
  has_secure_password

  enum role: { user: 0, trainer: 1, admin: 2 }

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: false
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validate :training_days_valid

  # Relationships
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships # Groups a user is a member of

  # If a user is a trainer for groups
  # has_many :coached_groups, class_name: 'Group', foreign_key: 'trainer_id', dependent: :nullify

  has_many :individual_training_schemas, class_name: 'TrainingSchema', foreign_key: 'user_id', dependent: :destroy
  has_many :training_sessions, dependent: :destroy # For individual training sessions created by/for the user
  
  has_many :attendances, dependent: :destroy
  has_many :trainings, through: :attendances

  has_many :training_assignments
  has_many :trainingen, through: :training_assignments, source: :training

  has_many :performances, dependent: :destroy
  has_many :training_results, dependent: :destroy

  has_many :hoofdtrainer_groepen, class_name: 'Group', foreign_key: 'hoofdtrainer_id', dependent: :nullify
  has_many :medetrainer_groepen, class_name: 'Group', foreign_key: 'medetrainer_id', dependent: :nullify

  belongs_to :status, optional: true

  belongs_to :default_training_schema, class_name: 'TrainingSchema', optional: true

  before_validation :sync_roles

  # Helper methods
  def member_of?(group)
    groups.include?(group)
  end

  def coaches_group?(group)
    # coached_groups.include?(group)
  end

  def admin?
    # Check nieuwe roles array (prioriteit)
    return true if has_role?(:admin)
    # Check oude role enum (fallback)
    return true if role == 'admin' || self[:role] == 2
    false
  end

  def attended_trainings_count_up_to_today
    attendances
      .where(status: :aanwezig)
      .joins(:training_session)
      .where('training_sessions.date IS NOT NULL')
      .where('training_sessions.date < ?', Date.current)
      .count
  end

  scope :actief, -> { joins(:status).where(statuses: { name: 'actief' }) }

  def training_days_valid
    allowed = %w[Dinsdag Zaterdag]
    if training_days.any? { |d| !allowed.include?(d) }
      errors.add(:training_days, 'mag alleen Dinsdag en/of Zaterdag bevatten')
    end
  end

  # Multirollen helpers
  def has_role?(role)
    (roles || []).include?(role.to_s)
  end

  def add_role(role)
    update(roles: (roles || []).push(role.to_s).uniq)
  end

  def remove_role(role)
    update(roles: (roles || []).reject { |r| r == role.to_s })
  end

  scope :with_role, ->(role) { where("roles @> ARRAY[?]::varchar[]", role.to_s) }

  # Voor backwards compatibility
  def role
    roles&.first || 'user'
  end

  scope :alleen_actieve_lopers, -> { joins(:status).where(statuses: { name: 'actief' }).where("roles @> ARRAY[?]::varchar[]", 'user') }

  # --- Gemiddelde conditiewaarden ---
  def gemiddelde_ad
    waardes = performances.map { |p| tijd_naar_seconden(ad(p)) }.select { |s| s > 0 }
    return '' if waardes.empty?
    seconden_naar_tijd((waardes.sum / waardes.size.to_f).round)
  end

  def gemiddelde_dl2_85
    waardes = performances.map { |p| tijd_naar_seconden(dl2_85(p)) }.select { |s| s > 0 }
    return '' if waardes.empty?
    seconden_naar_tijd((waardes.sum / waardes.size.to_f).round)
  end

  # Gemiddelde 10 km-prognose (op basis van prestaties)
  # Berekend met Riegel (exponent 1,06) en geaverageerd over alle prestaties
  def gemiddelde_prognose_10km
    vals = performances.map do |p|
      tijd = tijd_naar_seconden(p.value)
      afstand = p.distance.to_f
      next if tijd.zero? || afstand.zero?
      tijd * (10000.0 / afstand) ** 1.06
    end.compact
    return '' if vals.empty?
    seconden_naar_tijd((vals.sum / vals.size).round)
  end

  # --- Hulpfuncties voor conditie ---
  def tijd_naar_seconden(tijd)
    return 0 unless tijd
    delen = tijd.split(":").map(&:to_i)
    case delen.size
    when 3 then delen[0]*3600 + delen[1]*60 + delen[2]
    when 2 then delen[0]*60 + delen[1]
    when 1 then delen[0]
    else 0
    end
  end

  def seconden_naar_tijd(seconden)
    return "" unless seconden
    h = seconden / 3600
    m = (seconden % 3600) / 60
    s = seconden % 60
    if h > 0
      "%02d:%02d:%02d" % [h, m, s]
    else
      "%02d:%02d" % [m, s]
    end
  end

  def ad(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    snelheid = afstand / tijd # m/s
    snelheid_ad = snelheid * 0.9
    tijd_per_km = 1000.0 / snelheid_ad
    seconden_naar_tijd(tijd_per_km.round)
  end

  def dl2_85(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    snelheid = afstand / tijd # m/s
    snelheid_dl2 = snelheid * 0.85
    tijd_per_km = 1000.0 / snelheid_dl2
    seconden_naar_tijd(tijd_per_km.round)
  end

  # --- Gemiddelde 400m tempo volgens Riegel 1,06 ---
  def gemiddelde_400m_tempo
    waardes = performances.map { |p| tijd_naar_seconden(riegel_400m(p)) }.select { |s| s > 0 }
    return '' if waardes.empty?
    seconden_naar_tijd((waardes.sum / waardes.size.to_f).round)
  end

  def riegel_400m(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return '' if tijd == 0 || afstand == 0
    prognose = tijd * (400.0 / afstand) ** 1.06
    seconden_naar_tijd(prognose.round)
  end

  # --- Gemiddeld tempo per km ---
  def gemiddelde_tempo_per_km
    waardes = performances.map { |p| tijd_naar_seconden(km_min(p)) }.select { |s| s > 0 }
    return '' if waardes.empty?
    seconden_naar_tijd((waardes.sum / waardes.size.to_f).round)
  end

  def km_min(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    tijd_per_km = tijd / (afstand / 1000.0)
    seconden_naar_tijd(tijd_per_km.round)
  end

  def tijd_voor_afstand(km, pace_mmss)
    sec_per_km = tijd_naar_seconden(pace_mmss)
    return '' if sec_per_km.zero?
    totaal_sec = (sec_per_km * km.to_f).round
    seconden_naar_tijd(totaal_sec)
  end

  # --- Tempozones helpers voor trainingen ---
  def tempo_extensief
    gemiddelde_ad.presence || gemiddelde_tempo_per_km
  end

  def tempo_intensief
    gemiddelde_dl2_85.presence || gemiddelde_tempo_per_km
  end

  def tempo_interval
    gemiddelde_400m_tempo.presence || gemiddelde_tempo_per_km
  end

  # Intervaltempo omgerekend naar min/km op basis van 400m tempo
  def tempo_interval_km
    km_avg = gemiddelde_tempo_per_km
    return km_avg if km_avg.present? && km_avg != ''

    t400 = gemiddelde_400m_tempo
    return '' if t400.blank?
    sec_400 = tijd_naar_seconden(t400)
    return '' if sec_400.zero?
    sec_km  = sec_400 * 2.5  # 1000m / 400m
    seconden_naar_tijd(sec_km.round)
  end

  def tempo_sprint
    'max'
  end

  # --- Traininggemiddelden (voor toekomstige log resultaten) ---
  def average_training_tempo(type)
    valid_results = training_results.where.not(time: nil, distance: nil).select { |tr| tr.time.to_i >= 30 && tr.distance.to_f >= 0.2 }
    return nil if valid_results.empty?

    # Gemiddelde basistempo (sec per km) uit trainingslogs
    base_paces_sec = valid_results.map { |tr| tr.time.to_f / tr.distance.to_f }
    avg_sec_raw = (base_paces_sec.sum / base_paces_sec.size)

    case type
    when 'duur'
      # 85% van snelheid => pace / 0.85
      pace_sec = (avg_sec_raw / 0.85).round
      seconden_naar_tijd(pace_sec)
    when 'interval'
      # Riegel 1,06: predict 400m tempo uit km-tijd en herleiden naar km-intervaltempo
      factor = ((400.0/1000.0) ** 1.06) * 2.5 # terug naar 1 km
      pace_sec = (avg_sec_raw * factor).round
      seconden_naar_tijd(pace_sec)
    else
      nil
    end
  end

  def effective_training_tempo(type)
    avg = average_training_tempo(type)
    return avg if avg.present?

    case type
    when 'duur'
      tempo_intensief
    when 'interval'
      tempo_interval_km
    else
      tempo_interval_km
    end
  end

  # --- Training Anaerobe Drempel ---
  # Anaerobe drempel volgens opgegeven formule:
  # 1. 10 km prognose t10 = time * (10 / distance_km) ** 1.06
  # 2. AD-pace per km = (t10 / 10) * 0.94444 + 1 seconde
  def ad_training(tr)
    return '' unless tr&.time && tr&.distance && tr.time.to_i > 0 && tr.distance.to_f > 0
    return '' if tr.time.to_f < 30 || tr.distance.to_f < 0.2
    # AD-trainingtempo = basispace (tijd / afstand)
    ad_sec_per_km = tr.time.to_f / tr.distance.to_f
    seconden_naar_tijd(ad_sec_per_km.round)
  end

  def gemiddelde_training_ad
    secs = training_results.map { |tr| tijd_naar_seconden(ad_training(tr)) }.select { |s| s > 0 }
    return '' if secs.empty?
    seconden_naar_tijd((secs.sum / secs.size.to_f).round)
  end

  def training_prognose_10km
    vals = training_results.where.not(time: nil, distance: nil).map do |tr|
      next if tr.distance.to_f <= 0 || tr.time.to_i <= 0
      tr.time.to_f * (10.0 / tr.distance.to_f) ** 1.06
    end.compact
    return '' if vals.empty?
    seconden_naar_tijd((vals.sum / vals.size).round)
  end

  # --- Password reset helpers ---
  def generate_password_reset_token!
    token = SecureRandom.hex(16)
    update!(reset_password_token: token, reset_password_sent_at: Time.current)
    token
  end

  def clear_password_reset_token!
    update_columns(reset_password_token: nil, reset_password_sent_at: nil)
  end

  def password_reset_expired?
    reset_password_sent_at && reset_password_sent_at < 2.hours.ago
  end

  before_create :generate_public_token, :generate_slug

  private

  def sync_roles
    selected_roles = (self.roles || []).map(&:to_s).reject(&:blank?)
    selected_roles = [self[:role].to_s] if selected_roles.empty? && self[:role].present?
    selected_roles = ['user'] if selected_roles.empty?
    self.roles = selected_roles
    primary = selected_roles.first
    self[:role] = User.roles[primary] if primary && User.roles.key?(primary)
  end

  def generate_public_token
    self.public_token ||= SecureRandom.hex(16)
  end

  def generate_slug
    self.slug ||= name.to_s.parameterize
  end
end
