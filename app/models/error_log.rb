class ErrorLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :resolver, class_name: 'User', foreign_key: 'resolved_by', optional: true
  
  before_validation :generate_code, on: :create
  
  validates :code, presence: true, uniqueness: true
  
  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :recent, -> { order(last_occurrence_at: :desc) }
  scope :by_class, ->(error_class) { where(error_class: error_class) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Time.current.beginning_of_week) }
  scope :this_month, -> { where('created_at >= ?', Time.current.beginning_of_month) }
  
  def self.log_error(exception, request: nil, user: nil, extra_data: {})
    # Zoek bestaande error met dezelfde class en message (onopgelost)
    error_signature = "#{exception.class.name}:#{exception.message&.truncate(500)}"
    
    existing_error = unresolved
      .where(error_class: exception.class.name)
      .where("error_message = ? OR error_message LIKE ?", 
             exception.message, 
             "#{exception.message&.truncate(100)}%")
      .order(created_at: :desc)
      .first
    
    if existing_error
      # Update bestaande error: verhoog counter en update timestamps
      existing_error.increment!(:occurrence_count)
      existing_error.update_columns(
        last_occurrence_at: Time.current,
        url: request&.original_url || existing_error.url,
        ip_address: request&.remote_ip || existing_error.ip_address
      )
      
      Rails.logger.error "[ERROR-#{existing_error.code}] (x#{existing_error.occurrence_count}) #{exception.class}: #{exception.message}"
      
      existing_error
    else
      # Nieuwe error: maak nieuwe log aan
      error_log = create!(
        error_class: exception.class.name,
        error_message: exception.message,
        backtrace: exception.backtrace&.join("\n"),
        url: request&.original_url,
        request_method: request&.request_method,
        user_id: user&.id,
        ip_address: request&.remote_ip,
        user_agent: request&.user_agent,
        params: request&.params&.to_json,
        session_data: extra_data[:session_data]&.to_json,
        resolved: false,
        occurrence_count: 1,
        first_occurrence_at: Time.current,
        last_occurrence_at: Time.current,
        user_friendly_description: generate_user_friendly_description(exception, request)
      )
      
      Rails.logger.error "[ERROR-#{error_log.code}] (NEW) #{exception.class}: #{exception.message}"
      Rails.logger.error exception.backtrace&.first(10)&.join("\n")
      
      error_log
    end
  end
  
  def resolve!(resolver_user, notes: nil)
    update!(
      resolved: true,
      resolved_at: Time.current,
      resolved_by: resolver_user.id,
      notes: notes
    )
  end
  
  def reopen!
    update!(
      resolved: false,
      resolved_at: nil,
      resolved_by: nil
    )
  end
  
  def short_message
    error_message&.truncate(100)
  end
  
  def backtrace_lines
    backtrace&.split("\n") || []
  end
  
  def user_info
    return "Gast" unless user
    "#{user.name} (ID: #{user.id})"
  end
  
  private
  
  def generate_code
    # Genereer unieke foutcode: ERR-YYYYMMDD-XXXX
    date_part = Time.current.strftime('%Y%m%d')
    
    loop do
      random_part = SecureRandom.hex(2).upcase
      self.code = "ERR-#{date_part}-#{random_part}"
      break unless ErrorLog.exists?(code: code)
    end
  end
  
  def self.generate_user_friendly_description(exception, request)
    # Genereer automatisch een gebruiksvriendelijke beschrijving
    case exception.class.name
    when 'ActionView::Template::Error'
      if exception.message.include?('undefined method')
        method_name = exception.message.match(/undefined method [`'](\w+)['`]/)&.[](1)
        "Er is een technisch probleem opgetreden bij het laden van de pagina. " \
        "De ontwikkelaar is op de hoogte gesteld. Probeer de pagina opnieuw te laden."
      else
        "Er ging iets mis bij het weergeven van deze pagina. " \
        "Probeer het opnieuw of neem contact op met de beheerder."
      end
    when 'ActionView::SyntaxErrorInTemplate'
      "Er is een fout in de opmaak van de pagina. " \
      "De ontwikkelaar lost dit zo snel mogelijk op. Probeer het later opnieuw."
    when 'ActiveRecord::RecordNotFound'
      "De gevraagde informatie kon niet worden gevonden. " \
      "Mogelijk is deze verwijderd of bestaat deze niet (meer)."
    when 'ActionController::RoutingError'
      "De pagina die je probeert te bereiken bestaat niet. " \
      "Controleer de URL of ga terug naar de homepage."
    when 'NoMethodError'
      "Er is een technische fout opgetreden in de applicatie. " \
      "De ontwikkelaar is automatisch op de hoogte gesteld."
    when 'StandardError'
      if exception.message.include?('TEST')
        "Dit is een test-error voor demonstratie doeleinden."
      else
        "Er is een onverwachte fout opgetreden. " \
        "Probeer het opnieuw of neem contact op met de beheerder als het probleem aanhoudt."
      end
    else
      "Er ging iets onverwachts mis. " \
      "De beheerder is automatisch op de hoogte gesteld. " \
      "Probeer het opnieuw of neem contact op als het probleem aanhoudt."
    end
  end
end
