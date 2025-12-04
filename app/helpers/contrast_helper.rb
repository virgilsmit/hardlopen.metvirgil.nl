module ContrastHelper
  # Calculate relative luminance (WCAG 2.1 formula)
  def calculate_luminance(hex_color)
    # Remove # if present
    hex = hex_color.gsub('#', '')
    
    # Convert to RGB
    r, g, b = hex.scan(/../).map { |c| c.to_i(16) / 255.0 }
    
    # Apply gamma correction
    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055)**2.4
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055)**2.4
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055)**2.4
    
    # Calculate luminance
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end
  
  # Calculate contrast ratio between two colors
  def contrast_ratio(color1, color2)
    l1 = calculate_luminance(color1)
    l2 = calculate_luminance(color2)
    
    lighter = [l1, l2].max
    darker = [l1, l2].min
    
    (lighter + 0.05) / (darker + 0.05)
  end
  
  # Check if background is light or dark
  def light_background?(hex_color)
    luminance = calculate_luminance(hex_color)
    luminance > 0.5
  end
  
  # Get safe text color for background
  def safe_text_color(bg_color)
    light_background?(bg_color) ? '#1a1a1a' : '#f4f8ff'
  end
  
  # Get WCAG compliant text color
  def wcag_compliant_text(bg_color, prefer_dark: false)
    light_bg = light_background?(bg_color)
    
    if light_bg
      # Light background = use dark text
      dark_options = ['#1a1a1a', '#2a2a2a', '#3a3a3a']
      dark_options.find { |color| contrast_ratio(bg_color, color) >= 4.5 } || '#000000'
    else
      # Dark background = use light text  
      light_options = ['#f4f8ff', '#ffffff', '#e4e8ef']
      light_options.find { |color| contrast_ratio(bg_color, color) >= 4.5 } || '#ffffff'
    end
  end
  
  # Generate CSS for safe contrast
  def safe_contrast_style(bg_color)
    text_color = safe_text_color(bg_color)
    "background-color: #{bg_color}; color: #{text_color};"
  end
  
  # Check if contrast meets WCAG AA standard
  def wcag_aa_compliant?(bg_color, text_color, large_text: false)
    ratio = contrast_ratio(bg_color, text_color)
    required_ratio = large_text ? 3.0 : 4.5
    ratio >= required_ratio
  end
end

