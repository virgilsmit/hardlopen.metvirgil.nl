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
      { key: 'dezeweek', label: 'Deze week', url: '/schema/dezeweek' },
      { key: 'profile', label: 'Mijn Profiel', url: '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', url: '/schema/alle' },
      { key: 'groups', label: 'Groepen', url: '/groups' },
      { key: 'users', label: 'Hardlopers', url: '/users' },
      { key: 'photos', label: 'Foto\'s', url: '/photos' },
      { key: 'about', label: 'Over Ons', url: '/about' },
      { key: 'schema', label: 'Schema', url: '/schema' },
      { key: 'import', label: 'Importeren', url: '/import' },
      { key: 'statuses', label: 'Statussen', url: '/statuses' },
      { key: 'admin', label: 'Admin dashboard', url: '/admin' },
      { key: 'trainers', label: 'Trainerspagina', url: '/trainers' },
      { key: 'trainers_overzicht', label: 'Trainers Overzicht', url: '/trainers/overzicht' },
      { key: 'ad_gemiddelden', label: 'Gemiddelde AD Lopers', url: '/trainers/ad_gemiddelden' },
      { key: 'vandaag', label: 'Vandaag afmelden', url: '/training_sessions/vandaag' },
      { key: 'my_trainings', label: 'Mijn trainingen', url: '/mijntrainingen' },
      { key: 'profiles', label: 'Profielen', url: '/users' },
      { key: 'log_bulk', label: 'Aanwezig loggen', url: '/schema/dezeweek' }
    ]
    # Admins zien altijd alles
    if roles.include?('admin')
      return tiles.sort_by { |tile| tile[:position] || 999 }
    end
    # Verzamel alle tile assignments voor alle rollen
    assignments = TileAssignment.where(role: roles).group_by(&:tile_key)
    # Toon een tegel als deze voor één van de rollen zichtbaar is
    tiles
      .select { |tile| assignments[tile[:key]].blank? || assignments[tile[:key]].any? { |a| a.show_in_menu } }
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
      { key: 'dezeweek', label: 'Deze week', icon: '🗓️', desc: 'Bekijk de trainingen van deze week en meld je aan of af.', url: '/schema/dezeweek' },
      { key: 'profile', label: 'Mijn Profiel', icon: '👤', desc: 'Bekijk en bewerk je profiel en prestaties.', url: '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', icon: '📅', desc: 'Bekijk het volledige trainingsschema.', url: '/schema/alle' },
      { key: 'groups', label: 'Groepen', icon: '👥', desc: 'Bekijk en beheer alle hardloopgroepen.', url: '/groups' },
      { key: 'users', label: 'Hardlopers', icon: '🏃‍♂️', desc: 'Bekijk alle lopers en hun profielen.', url: '/users' },
      { key: 'photos', label: 'Foto\'s', icon: '📸', desc: 'Bekijk sfeerimpressies en trainingsfoto\'s.', url: '/photos' },
      { key: 'about', label: 'Over Ons', icon: 'ℹ️', desc: 'Lees meer over de groep en trainers.', url: '/about' },
      { key: 'schema', label: 'Schema', icon: '📅', desc: 'Bekijk het volledige trainingsschema en het weekschema.', url: '/schema' },
      { key: 'import', label: 'Importeren', icon: '📥', desc: 'Importeer snel nieuwe hardlopers via CSV.', url: '/import' },
      { key: 'statuses', label: 'Statussen', icon: '🔄', desc: 'Bekijk en wijzig de status van alle lopers.', url: '/statuses' },
      { key: 'admin', label: 'Admin dashboard', icon: '🛠️', desc: 'Beheer de applicatie.', url: '/admin' },
      { key: 'trainers', label: 'Trainerspagina', icon: '🧑‍🏫', desc: 'Beheer trainers en zie trainersfunctionaliteit.', url: '/trainers' },
      { key: 'vandaag', label: 'Vandaag afmelden', icon: '📲', desc: 'Meld je snel aan of af voor de training van vandaag.', url: '/training_sessions/vandaag' },
      { key: 'tiles', label: 'Tegels beheren', icon: '🧩', desc: 'Wijs tegels toe aan rollen en beheer het dashboard.', url: '/admin/tiles' },
      { key: 'my_trainings', label: 'Mijn trainingen', icon: '📅', desc: 'Bekijk je eigen trainingen en prestaties.', url: '/mijntrainingen' },
      { key: 'profiles', label: 'Profielen', icon: '📂', desc: 'Bekijk alle lopersprofielen.', url: '/users' },
      { key: 'log_bulk', label: 'Aanwezig loggen', icon: '📝', desc: 'Log trainingresultaat voor aanwezige lopers.', url: '/schema/dezeweek' }
    ]
    if roles.include?('admin')
      return tiles.sort_by { |tile| tile[:position] || 999 }
    end
    assignments = TileAssignment.where(role: roles).group_by(&:tile_key)
    tiles
      .select { |tile| assignments[tile[:key]].blank? || assignments[tile[:key]].any? { |a| a.visible } }
      .map { |tile|
        assignment = roles.map { |r| assignments[tile[:key]]&.find { |a| a.role == r } }.compact.first
        tile.merge(label: assignment&.custom_label.presence || tile[:label], position: assignment&.position)
      }
      .sort_by { |tile| tile[:position] || 999 }
  end
end
