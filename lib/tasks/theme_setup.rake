namespace :theme do
  desc "Zet default custom CSS voor dropdown styling"
  task set_default_css: :environment do
    theme = Theme.first
    
    if theme.nil?
      puts "❌ Geen theme gevonden"
      exit
    end
    
    default_css = <<~CSS
/* Dropdown menu styling - volledig ondoorzichtig met witte tekst */
.dropdown-menu,
nav .dropdown-menu,
.theme-menu .dropdown-menu {
  background: #0e1935 !important;
  background-color: #0e1935 !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  opacity: 1 !important;
}

.dropdown-item,
.dropdown-menu a,
.dropdown-menu .dropdown-item {
  color: #f7fbff !important;
  background: transparent !important;
}

.dropdown-item:hover,
.dropdown-item:focus,
.dropdown-menu a:hover {
  background: rgba(255, 107, 53, 0.25) !important;
  color: #ffb193 !important;
}

/* Profile page headings */
.profile-page .profile-title,
.profile-page h1,
.profile-page h2,
.profile-page h3 {
  color: #ffffff !important;
  font-weight: 700 !important;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3) !important;
}

/* Menu buttons - minder transparant */
.theme-menu a,
.theme-menu button {
  background: rgba(255, 255, 255, 0.15) !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
}
CSS
    
    theme.update!(custom_css: default_css)
    puts "✓ Custom CSS toegevoegd aan theme '#{theme.name}'"
    puts "✓ Je kunt dit nu aanpassen via: #{ENV['APP_HOST'] || 'https://hardlopen.metvirgil.nl'}/admin/themes/#{theme.id}/edit"
  end
end


