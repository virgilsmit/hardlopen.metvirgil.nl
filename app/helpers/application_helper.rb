module ApplicationHelper
  # Helper voor app-achtige cards
  def app_card(options = {}, &block)
    content_tag :div, class: "app-card #{options[:class]}", &block
  end

  # Helper voor app-achtige buttons
  def app_button(text, url = nil, options = {})
    options[:class] = "app-btn #{options[:class]}"
    if url
      link_to text, url, options
    else
      content_tag :button, text, options
    end
  end

  # Helper voor app-achtige lists
  def app_list(options = {}, &block)
    content_tag :div, class: "app-list #{options[:class]}", &block
  end

  # Helper voor app-achtige list items
  def app_list_item(options = {}, &block)
    content_tag :div, class: "app-list-item #{options[:class]}", &block
  end

  # Helper voor app-achtige form groups
  def app_form_group(options = {}, &block)
    content_tag :div, class: "app-form-group #{options[:class]}", &block
  end

  # Helper voor app-achtige form labels
  def app_form_label(text, options = {})
    content_tag :label, text, class: "app-form-label #{options[:class]}"
  end

  # Helper voor app-achtige form inputs
  def app_form_input(type, name, options = {})
    options[:class] = "app-form-input #{options[:class]}"
    text_field_tag name, nil, options.merge(type: type)
  end

  # Helper voor loading states
  def app_loading(text = "Laden...")
    content_tag :div, class: "app-loading" do
      content_tag(:div, "", class: "app-loading__spinner") +
      content_tag(:span, text)
    end
  end

  # Helper voor app-achtige notifications
  def app_notification(message, type = "info")
    content_tag :div, message, class: "app-notification app-notification--#{type}"
  end

  # Zet structured_core om naar leesbare regels per segment voor een gebruiker
  def human_core(structured_core, user = nil)
    return [] if structured_core.blank?
    structured_core.map do |seg|
      pace = if user
        t = (seg[:type] || seg['type']).to_s
        if t.include?('duur') || t.include?('herstel')
          user.tempo_intensief   # Duurloop 85%
        else
          user.tempo_interval_km # Intervaltempo omgezet naar min/km
        end
      else
        seg['intensiteit']
      end
      rep_key = seg[:herhalingen] || seg['herhalingen']
      rep = rep_key.to_i > 1 ? "#{rep_key}× " : ''
      val = seg[:value] || seg['value']
      unit = seg[:unit] || seg['unit']
      unit = 'min' if unit == 'm'
      display_val = (val && val % 1 == 0) ? val.to_i : val
      dur = val && unit ? "#{display_val} #{unit}" : (seg[:duur] || seg['duur'])
      suffix = (t.include?('duur') || t.include?('herstel')) ? '' : ' min/km'
      "#{rep}#{dur} – #{seg[:type]} – tempo #{pace}#{suffix}"
    end
  end

  def visible_tiles_for_menu(user)
    roles = (user&.roles.presence || ['user']).map(&:to_s)
    tiles = [
      { key: 'home', label: 'Home', url: '/' },
      { key: 'login', label: 'Login', url: '/login' },
      { key: 'register', label: 'Registreren', url: '/register' },
      { key: 'intake', label: 'Intake', url: '/intake' },
      { key: 'dezeweek', label: 'Deze week', url: user_schema_path(user, :dezeweek) },
      { key: 'profile', label: 'Mijn Profiel', url: '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', url: user_schema_path(user, :alle) },
      { key: 'my_trainings', label: 'Mijn trainingen', url: '/mijntrainingen' },
      { key: 'groups', label: 'Groepen', url: '/groups' },
      { key: 'users', label: 'Hardlopers', url: '/users' },
      { key: 'photos', label: 'Foto\'s', url: '/photos' },
      { key: 'about', label: 'Over Ons', url: '/about' },
      { key: 'schema', label: 'Schema', url: user_schema_path(user, :schema) },
      { key: 'import', label: 'Importeren', url: '/import' },
      { key: 'statuses', label: 'Statussen', url: '/statuses' },
      { key: 'admin', label: 'Admin dashboard', url: '/admin' },
      { key: 'trainers', label: 'Trainerspagina', url: '/trainers' },
      { key: 'trainers_overzicht', label: 'Trainers Overzicht', url: '/trainers/overzicht' },
      { key: 'ad_gemiddelden', label: 'Gemiddelde AD Lopers', url: '/trainers/ad_gemiddelden' },
      { key: 'birthdays', label: 'Alle verjaardagen', url: '/trainers/verjaardagen' },
      { key: 'birthdays_30', label: 'Komende verjaardagen', url: '/verjaardagen/komende' },
      { key: 'vandaag', label: 'Vandaag afmelden', url: '/training_sessions/vandaag' },
      { key: 'profiles', label: 'Profielen', url: '/users' },
      { key: 'log_bulk', label: 'Aanwezig loggen', url: user_schema_path(user, :dezeweek) },
      { key: 'intakes', label: 'Intake-aanvragen', url: '/admin/intakes' }
    ]
    # Admins zien altijd alles
    if roles.include?('admin')
      return tiles.sort_by { |tile| tile[:position] || 999 }
    end
    # Verzamel alle tile assignments voor alle rollen
    assignments = TileAssignment.where(role: roles).group_by(&:tile_key)
    # Toon een tegel als deze voor één van de rollen zichtbaar is
    tiles
      .select { |tile| 
        # Als er assignments zijn voor deze tile
        if assignments[tile[:key]].present?
          # Toon alleen als er een assignment is met show_in_menu expliciet true
          # Als show_in_menu false is, verberg de tile
          assignments[tile[:key]].any? { |a| a.show_in_menu == true }
        else
          # Als er geen assignments zijn, toon hem standaard (backwards compatibility)
          true
        end
      }
      .map { |tile|
        # Kies de assignment met hoogste prioriteit (admin > trainer > user)
        assignment = roles.map { |r| assignments[tile[:key]]&.find { |a| a.role == r } }.compact.first
        tile.merge(label: assignment&.custom_label.presence || tile[:label], position: assignment&.position)
      }
      .sort_by { |tile| tile[:position] || 999 }
  end

  def visible_tiles_for_dashboard(user)
    roles = (user&.roles.presence || ['user']).map(&:to_s)
    tiles = [
      { key: 'home', label: 'Home', icon: '🏠', desc: 'Homepagina', url: '/' },
      { key: 'login', label: 'Login', icon: '🔑', desc: 'Inlogpagina', url: '/login' },
      { key: 'register', label: 'Registreren', icon: '📝', desc: 'Registratiepagina voor nieuwe gebruikers', url: '/register' },
      { key: 'intake', label: 'Intake', icon: '📝', desc: 'Publiek intake formulier', url: '/intake' },
      { key: 'dezeweek', label: 'Deze week', icon: '🗓️', desc: 'Bekijk de trainingen van deze week en meld je aan of af.', url: user_schema_path(user, :dezeweek) },
      { key: 'profile', label: 'Mijn Profiel', icon: '👤', desc: 'Bekijk en bewerk je profiel en prestaties.', url: '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', icon: '📅', desc: 'Bekijk het volledige trainingsschema.', url: user_schema_path(user, :alle) },
      { key: 'my_trainings', label: 'Mijn trainingen', icon: '📅', desc: 'Bekijk je eigen trainingen en prestaties.', url: '/mijntrainingen' },
      { key: 'groups', label: 'Groepen', icon: '👥', desc: 'Bekijk en beheer alle hardloopgroepen.', url: '/groups' },
      { key: 'users', label: 'Hardlopers', icon: '🏃‍♂️', desc: 'Bekijk alle lopers en hun profielen.', url: '/users' },
      { key: 'photos', label: 'Foto\'s', icon: '📸', desc: 'Bekijk sfeerimpressies en trainingsfoto\'s.', url: '/photos' },
      { key: 'about', label: 'Over Ons', icon: 'ℹ️', desc: 'Lees meer over de groep en trainers.', url: '/about' },
      { key: 'schema', label: 'Schema', icon: '📅', desc: 'Bekijk het volledige trainingsschema en het weekschema.', url: user_schema_path(user, :schema) },
      { key: 'import', label: 'Importeren', icon: '📥', desc: 'Importeer snel nieuwe hardlopers via CSV.', url: '/import' },
      { key: 'statuses', label: 'Statussen', icon: '🔄', desc: 'Bekijk en wijzig de status van alle lopers.', url: '/statuses' },
      { key: 'admin', label: 'Admin dashboard', icon: '🛠️', desc: 'Beheer de applicatie.', url: '/admin' },
      { key: 'trainers', label: 'Trainerspagina', icon: '🧑‍🏫', desc: 'Beheer trainers en zie trainersfunctionaliteit.', url: '/trainers' },
      { key: 'vandaag', label: 'Vandaag afmelden', icon: '📲', desc: 'Meld je snel aan of af voor de training van vandaag.', url: '/training_sessions/vandaag' },
      { key: 'tiles', label: 'Tegels beheren', icon: '🧩', desc: 'Wijs tegels toe aan rollen en beheer het dashboard.', url: '/admin/tiles' },
      { key: 'birthdays', label: 'Alle verjaardagen', icon: '🎂', desc: 'Bekijk alle verjaardagen van lopers.', url: '/trainers/verjaardagen' },
      { key: 'birthdays_30', label: 'Komende verjaardagen', icon: '🎉', desc: 'Verjaardagen in de komende 30 dagen.', url: '/verjaardagen/komende' },
      { key: 'profiles', label: 'Profielen', icon: '📂', desc: 'Bekijk alle lopersprofielen.', url: '/users' },
      { key: 'log_bulk', label: 'Aanwezig loggen', icon: '📝', desc: 'Log trainingresultaat voor aanwezige lopers.', url: user_schema_path(user, :dezeweek) },
      { key: 'intakes', label: 'Intake-aanvragen', icon: '📋', desc: 'Bekijk en verwerk nieuwe intake aanvragen.', url: '/admin/intakes' }
    ]
    if roles.include?('admin')
      return tiles.sort_by { |tile| tile[:position] || 999 }
    end
    assignments = TileAssignment.where(role: roles).group_by(&:tile_key)
    tiles
      .select { |tile| 
        # Als er geen assignments zijn voor deze tile, toon hem standaard
        if assignments[tile[:key]].blank?
          true
        else
          # Als er assignments zijn, toon alleen als er een zichtbaar is
          assignments[tile[:key]].any? { |a| a.visible }
        end
      }
      .map { |tile|
        assignment = roles.map { |r| assignments[tile[:key]]&.find { |a| a.role == r } }.compact.first
        tile.merge(label: assignment&.custom_label.presence || tile[:label], position: assignment&.position)
      }
      .sort_by { |tile| tile[:position] || 999 }
  end

  # Helper om te controleren of de Apple Watch download knop zichtbaar moet zijn voor een gebruiker
  def show_apple_watch_download?(user)
    return false unless user
    
    roles = (user.roles.presence || ['user']).map(&:to_s)
    
    # Admins zien altijd de knop
    return true if roles.include?('admin')
    
    # Controleer tile assignments voor de apple_watch_download tile
    assignments = TileAssignment.where(role: roles, tile_key: 'apple_watch_download')
    
    # Toon de knop als er een assignment is die show_apple_watch_download op true heeft
    assignments.any? { |assignment| assignment.show_apple_watch_download == true }
  end

  # Helper om de juiste schema URL te genereren op basis van het standaard schema van de gebruiker
  def user_schema_path(user = current_user, path_type = :index)
    return schema_path unless user&.default_training_schema
    
    case path_type
    when :index, :schema
      schema_volledig_path(id: user.default_training_schema.id)
    when :week, :dezeweek
      schema_dezeweek_path
    when :all, :alle
      schema_all_path
    else
      schema_path
    end
  end
end
