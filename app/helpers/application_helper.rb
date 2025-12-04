module ApplicationHelper
  # Always return current time - never cached
  def current_version_time
    Time.current.strftime('%H:%M')
  end
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

  def shortcut_tiles_for_menu(user)
    roles = (user&.roles.presence || ['user']).map(&:to_s)
    
    # Haal alle tiles op die als shortcut zijn gemarkeerd
    TileAssignment.where(role: roles, show_as_shortcut: true)
      .order(:position)
      .map do |assignment|
        # Vind de tile definitie
        tile_def = all_tiles_definition(user).find { |t| t[:key] == assignment.tile_key }
        next unless tile_def
        
        {
          key: assignment.tile_key,
          label: assignment.custom_menu_label.presence || assignment.custom_label.presence || tile_def[:label],
          url: tile_def[:url],
          position: assignment.position
        }
      end.compact
  end
  
  def tiles_for_dropdown(user, parent_menu_key)
    roles = (user&.roles.presence || ['user']).map(&:to_s)
    
    # Haal alle tiles op die in dit dropdown menu moeten verschijnen
    assignments = TileAssignment.where(role: roles, parent_menu: parent_menu_key, show_in_parent_dropdown: true)
      .order(:position)
    
    # Groepeer assignments per tile_key
    assignments_by_key = assignments.group_by(&:tile_key)
    
    # Voor elke tile_key, kies de assignment met hoogste prioriteit (admin > trainer > user)
    assignments_by_key.map do |tile_key, tile_assignments|
      # Kies assignment met hoogste prioriteit
      assignment = roles.map { |r| tile_assignments.find { |a| a.role == r } }.compact.first
      next unless assignment
      
      tile_def = all_tiles_definition(user).find { |t| t[:key] == assignment.tile_key }
      next unless tile_def
      
      {
        key: assignment.tile_key,
        label: assignment.custom_menu_label.presence || assignment.custom_label.presence || tile_def[:label],
        url: tile_def[:url],
        position: assignment.position
      }
    end.compact.sort_by { |tile| tile[:position] || 999 }
  end
  
  def bottom_nav_tiles(user)
    roles = (user&.roles.presence || ['user']).map(&:to_s)
    
    # Haal alle tiles op die in het bottom navigation menu moeten verschijnen
    assignments = TileAssignment.where(role: roles, show_in_bottom_nav: true)
      .order(:bottom_nav_position)
    
    # Groepeer assignments per tile_key om duplicaten te voorkomen
    assignments_by_key = assignments.group_by(&:tile_key)
    
    # Voor elke tile_key, kies de assignment met hoogste prioriteit (admin > trainer > user)
    assignments_by_key.map do |tile_key, tile_assignments|
      # Kies assignment met hoogste prioriteit
      assignment = roles.map { |r| tile_assignments.find { |a| a.role == r } }.compact.first
      next unless assignment
      
      tile_def = all_tiles_definition(user).find { |t| t[:key] == assignment.tile_key }
      next unless tile_def
      
      {
        key: assignment.tile_key,
        label: assignment.bottom_nav_label.presence || assignment.custom_label.presence || tile_def[:label],
        icon: assignment.bottom_nav_icon.presence || '📄',
        url: tile_def[:url],
        position: assignment.bottom_nav_position || 999
      }
    end.compact.sort_by { |tile| tile[:position] }.take(5) # Max 5 items in bottom nav
  end
  
  def all_tiles_definition(user)
    [
      # Publiek
      { key: 'home', label: 'Home', url: '/' },
      { key: 'login', label: 'Login', url: '/login' },
      { key: 'register', label: 'Registreren', url: '/register' },
      { key: 'intake', label: 'Intake', url: '/intake' },
      { key: 'about', label: 'Over Ons', url: '/about' },
      
      # Training
      { key: 'dezeweek', label: 'Deze week', url: user ? user_schema_path(user, :dezeweek) : '/schema/dezeweek' },
      { key: 'all_trainings', label: 'Alle trainingen', url: user ? user_schema_path(user, :alle) : '/schema/alle' },
      { key: 'my_trainings', label: 'Mijn trainingen', url: '/mijntrainingen' },
      { key: 'schema', label: 'Schema', url: user ? user_schema_path(user, :schema) : '/schema' },
      { key: 'vandaag', label: 'Vandaag', url: '/training_sessions/vandaag' },
      { key: 'zones', label: 'Zones & drempel', url: user ? zones_user_path(user) : '/profile' },
      
      # Profiel
      { key: 'profile', label: 'Mijn Profiel', url: '/profile' },
      { key: 'users', label: 'Hardlopers', url: '/users' },
      { key: 'performances', label: 'Prestaties', url: '/performances' },
      { key: 'events', label: 'Hardloop Evenementen', url: '/events' },
      
      # Beheer
      { key: 'groups', label: 'Groepen', url: '/groups' },
      { key: 'statuses', label: 'Statussen', url: '/statuses' },
      { key: 'photos', label: 'Foto\'s', url: '/photos' },
      { key: 'drills', label: 'Oefeningen', url: '/drills' },
      { key: 'routes', label: 'Routes', url: '/routes' },
      { key: 'vacations', label: 'Vakanties', url: '/vacations' },
      
      # Trainers
      { key: 'trainers', label: 'Trainerspagina', url: '/trainers' },
      { key: 'trainers_overzicht', label: 'Trainers Overzicht', url: '/trainers/overzicht' },
      { key: 'trainers_beheer', label: 'Trainers Beheer', url: '/trainers/beheer' },
      { key: 'ad_gemiddelden', label: 'Gemiddelde AD', url: '/trainers/ad_gemiddelden' },
      { key: 'trainers_tijden', label: 'Trainers Tijden', url: '/trainers/tijden' },
      { key: 'birthdays', label: 'Alle verjaardagen', url: '/trainers/verjaardagen' },
      { key: 'birthdays_30', label: 'Komende verjaardagen', url: '/verjaardagen/komende' },
      { key: 'log_bulk', label: 'Aanwezig loggen', url: user ? user_schema_path(user, :dezeweek) : '/schema/dezeweek' },
      
      # Admin
      { key: 'admin', label: 'Admin dashboard', url: '/admin' },
      { key: 'tiles', label: 'Menu beheren', url: '/admin/tiles' },
      { key: 'themes', label: 'Thema beheer', url: '/admin/themes' },
      { key: 'site_contents', label: 'Hero Content', url: '/site_contents' },
      { key: 'intakes', label: 'Intake-aanvragen', url: '/admin/intakes' },
      { key: 'admin_users', label: 'Gebruikers beheer', url: '/admin/users' },
      { key: 'admin_schemas', label: 'Schema\'s koppelen', url: '/admin/schemas/koppelen' },
      { key: 'login_logs', label: 'Login Log', url: '/admin/login_logs' },
      { key: 'import', label: 'Importeren', url: '/import' },
      { key: 'import_history', label: 'Import Historie', url: '/import_history' }
    ]
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
      { key: 'zones', label: 'Zones & drempel', url: user ? zones_user_path(user) : '/profile' },
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
      { key: 'themes', label: 'Thema beheer', url: '/admin/themes' },
      { key: 'tiles', label: 'Menu beheren', url: '/admin/tiles' },
      { key: 'login_logs', label: 'Login Log', url: '/admin/login_logs' },
      { key: 'error_logs', label: 'Error Logs', url: '/admin/error_logs' },
      { key: 'error_messages', label: 'Foutmelding Beheer', url: '/admin/error_messages' },
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
    # Verzamel alle tile assignments ALLEEN voor de rollen van deze gebruiker
    user_assignments_by_key = TileAssignment.where(role: roles).group_by(&:tile_key)
    # Verzamel ook ALLE tile assignments om te zien welke tiles überhaupt geconfigureerd zijn
    all_assignments = TileAssignment.all.pluck(:tile_key).uniq
    
    # Toon een tegel als deze voor één van de rollen van de gebruiker zichtbaar is
    tiles
      .select { |tile| 
        # Check of deze tile key überhaupt assignments heeft (voor enige rol)
        if all_assignments.include?(tile[:key])
          # Er zijn assignments voor deze tile - check of gebruiker's rollen toegang hebben
          user_assignments = user_assignments_by_key[tile[:key]]
          if user_assignments.present?
            # Er is een assignment voor deze gebruiker's rol - check show_in_menu
            user_assignments.any? { |a| a.show_in_menu == true }
          else
            # Er zijn assignments maar niet voor deze gebruiker's rol - verberg
            false
          end
        else
          # Er zijn HELEMAAL GEEN assignments voor deze tile - toon standaard (backwards compatibility)
          true
        end
      }
      .map { |tile|
        # Kies de assignment met hoogste prioriteit (admin > trainer > user)
        assignment = roles.map { |r| user_assignments_by_key[tile[:key]]&.find { |a| a.role == r } }.compact.first
        tile.merge(
          label: assignment&.custom_menu_label.presence || assignment&.custom_label.presence || tile[:label],
          position: assignment&.position
        )
      }
      .sort_by { |tile| tile[:position] || 999 }
  end

  def menu_label_for(user, key, default_label)
    roles = (user&.roles.presence || ['user']).map(&:to_s)
    cache_key = "#{roles.join('-')}:#{key}"
    @menu_label_cache ||= {}
    return @menu_label_cache[cache_key] if @menu_label_cache.key?(cache_key)

    assignment = roles.map { |role|
      TileAssignment.find_by(role: role, tile_key: key)
    }.compact.first

    label = assignment&.custom_menu_label.presence || assignment&.custom_label.presence || default_label
    @menu_label_cache[cache_key] = label
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
      { key: 'zones', label: 'Zones & drempel', icon: '💓', desc: 'Bekijk je hartslagzones, drempelwaarden en prognoses.', url: user ? zones_user_path(user) : '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', icon: '📅', desc: 'Bekijk het volledige trainingsschema.', url: user_schema_path(user, :alle) },
      { key: 'my_trainings', label: 'Mijn trainingen', icon: '📅', desc: 'Bekijk je eigen trainingen en prestaties.', url: '/mijntrainingen' },
      { key: 'groups', label: 'Groepen', icon: '👥', desc: 'Bekijk en beheer alle hardloopgroepen.', url: '/groups' },
      { key: 'users', label: 'Hardlopers', icon: '🏃‍♂️', desc: 'Bekijk alle lopers en hun profielen.', url: '/users' },
      { key: 'events', label: 'Hardloop Evenementen', icon: '🏁', desc: 'Bekijk komende hardloop evenementen en wedstrijden.', url: '/events' },
      { key: 'photos', label: 'Foto\'s', icon: '📸', desc: 'Bekijk sfeerimpressies en trainingsfoto\'s.', url: '/photos' },
      { key: 'about', label: 'Over Ons', icon: 'ℹ️', desc: 'Lees meer over de groep en trainers.', url: '/about' },
      { key: 'schema', label: 'Schema', icon: '📅', desc: 'Bekijk het volledige trainingsschema en het weekschema.', url: user_schema_path(user, :schema) },
      { key: 'import', label: 'Importeren', icon: '📥', desc: 'Importeer snel nieuwe hardlopers via CSV.', url: '/import' },
      { key: 'statuses', label: 'Statussen', icon: '🔄', desc: 'Bekijk en wijzig de status van alle lopers.', url: '/statuses' },
      { key: 'admin', label: 'Admin dashboard', icon: '🛠️', desc: 'Beheer de applicatie.', url: '/admin' },
      { key: 'trainers', label: 'Trainerspagina', icon: '🧑‍🏫', desc: 'Beheer trainers en zie trainersfunctionaliteit.', url: '/trainers' },
      { key: 'vandaag', label: 'Vandaag afmelden', icon: '📲', desc: 'Meld je snel aan of af voor de training van vandaag.', url: '/training_sessions/vandaag' },
      { key: 'tiles', label: 'Tegels beheren', icon: '🧩', desc: 'Wijs tegels toe aan rollen en beheer het dashboard.', url: '/admin/tiles' },
      { key: 'error_logs', label: 'Error Logs', icon: '🚨', desc: 'Bekijk en beheer error logs en foutmeldingen.', url: '/admin/error_logs' },
      { key: 'error_messages', label: 'Foutmelding Beheer', icon: '💬', desc: 'Bewerk gebruikersvriendelijke foutmeldingen.', url: '/admin/error_messages' },
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

  # Helper om CSS variabelen te genereren vanuit het actieve thema
  def user_role_display(user)
    return 'Gebruiker' unless user
    
    # Haal de meest recente rollen op uit de database om cache te vermijden
    fresh_user = User.find_by(id: user.id)
    return 'Gebruiker' unless fresh_user
    
    # Haal alle rollen op en bepaal de hoogste
    user_roles = fresh_user.roles || []
    
    # Check voor hoogste rol eerst: admin > trainer > user
    if user_roles.include?('admin')
      'Admin'
    elsif user_roles.include?('trainer')
      'Trainer'
    else
      'Gebruiker'
    end
  end
  
  # Error logs helper
  def unresolved_error_count
    @unresolved_error_count ||= ErrorLog.unresolved.count
  end

  def theme_css_variables
    theme = Theme.current
    return '' unless theme
    
    # Bereken afgeleide kleuren (lichte en donkere varianten)
    primary_light = lighten_color(theme.primary_color, 0.2)
    primary_dark = darken_color(theme.primary_color, 0.1)
    
    css = <<~CSS
      :root {
        /* Basis kleuren */
        --color-primary: #{theme.primary_color};
        --color-primary-light: #{primary_light};
        --color-primary-dark: #{primary_dark};
        --color-secondary: #{theme.secondary_color};
        --color-accent: #{theme.accent_color};
        --color-success: #{theme.success_color};
        --color-warning: #{theme.warning_color};
        --color-danger: #{theme.danger_color};
        
        /* Achtergronden */
        --color-bg: #{theme.background_color};
        --color-bg-alt: #{theme.background_color_alt};
        --color-header: #{theme.header_background};
        --color-card: #{theme.card_background};
        --color-card-dark: #{theme.card_background_dark};
        
        /* Donkere thema achtergronden (voor compatibiliteit) */
        --color-bg-dark: #{theme.card_background_dark};
        --color-bg-alt-dark: #{darken_color(theme.card_background_dark, 0.05)};
        --color-header-dark: #{theme.header_background};
        
        /* Tekst kleuren */
        --color-text: #{theme.text_color_light};
        --color-text-dark: #{theme.text_color_dark};
        --color-text-muted: #{theme.text_color_muted};
        --color-text-muted-dark: #{theme.text_color_muted_dark};
        --color-heading: #{theme.text_color_light};
        --color-heading-dark: #{theme.text_color_dark};
        
        /* Borders */
        --color-border: #{theme.border_color};
        --color-border-dark: #{theme.border_color_dark};
        
        /* Typography */
        --font-family-primary: #{theme.font_family};
        --font-family-secondary: #{theme.font_family_secondary};
        --font-size-base: #{theme.font_size_base};
        --font-weight-normal: #{theme.font_weight_normal};
        --font-weight-semibold: #{theme.font_weight_semibold};
        --font-weight-bold: #{theme.font_weight_bold};
        
        /* Spacing */
        --spacing-unit: #{theme.spacing_unit};
        
        /* Border radius */
        --border-radius-small: #{theme.border_radius_small};
        --border-radius-medium: #{theme.border_radius_medium};
        --border-radius-large: #{theme.border_radius_large};
        
        /* Shadows */
        --shadow-small: #{theme.shadow_small};
        --shadow-medium: #{theme.shadow_medium};
        --shadow-large: #{theme.shadow_large};
        --color-btn-shadow: #{rgba_from_hex(theme.primary_color, 0.25)};
        --color-card-shadow: #{rgba_from_hex('#000000', 0.08)};
        
        /* Surface kleuren (voor compatibiliteit) */
        --surface-light-bg: #{theme.background_color};
        --surface-light-text: #{theme.text_color_light};
        --surface-light-muted: #{theme.text_color_muted};
        --surface-dark-bg: #{theme.header_background};
        --surface-dark-bg-alt: #{darken_color(theme.header_background, 0.05)};
        --surface-dark-text: #{theme.text_color_dark};
        --surface-dark-muted: #{theme.text_color_muted_dark};
      }
    CSS
    
    # Voeg custom CSS toe als die bestaat
    if theme.custom_css.present?
      css += "\n\n/* Custom CSS */\n#{theme.custom_css}\n"
    end
    
    content_tag :style, css.html_safe, type: 'text/css'
  end
  
  private
  
  # Helper om hex kleur lichter te maken
  def lighten_color(hex, amount)
    return hex unless hex&.match?(/\A#[0-9A-Fa-f]{6}\z/)
    rgb = hex_to_rgb(hex)
    rgb.map { |c| [(c + (255 - c) * amount).round, 255].min }
       .map { |c| format('%02X', c) }
       .join
       .prepend('#')
  end
  
  # Helper om hex kleur donkerder te maken
  def darken_color(hex, amount)
    return hex unless hex&.match?(/\A#[0-9A-Fa-f]{6}\z/)
    rgb = hex_to_rgb(hex)
    rgb.map { |c| [(c * (1 - amount)).round, 0].max }
       .map { |c| format('%02X', c) }
       .join
       .prepend('#')
  end
  
  # Converteer hex naar RGB array
  def hex_to_rgb(hex)
    hex.match(/\A#([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})\z/)&.captures&.map { |c| c.to_i(16) } || [0, 0, 0]
  end
  
  # Converteer hex naar rgba string
  def rgba_from_hex(hex, alpha)
    return "rgba(0, 0, 0, #{alpha})" unless hex&.match?(/\A#[0-9A-Fa-f]{6}\z/)
    rgb = hex_to_rgb(hex)
    "rgba(#{rgb.join(', ')}, #{alpha})"
  end
end
