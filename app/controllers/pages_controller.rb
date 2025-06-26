class PagesController < ApplicationController
  def home
    # This is the main landing page.
    # If the user is logged in, you might want to show a dashboard.
    # If not logged in, show a generic welcome message or a login/register prompt.
  end

  def about
    # Static page for "About Us" or similar information.
  end

  def contact
    # Static page for contact information or a contact form.
  end

  # Add other static pages as needed
end
