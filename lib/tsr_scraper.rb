require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

class TSRScraper
  include Capybara::DSL

  def initialize(username, password, start_date)
    @username = username
    @password = password
    @start_date = start_date

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.current_driver = :poltergeist
    Capybara.app_host = 'http://thesquatrack.com'
    Capybara.default_wait_time = 20
  end

  def log_in
    visit "/login"
    fill_in "username", with: @username
    fill_in "password", with: @password
    click_on "Login to TheSquatRack"
    sleep 2
  end

  def export_all
    visit "/dashboard"
    export_workouts
  end

  private
  def export_workouts
    export_current_month

    if current_date != @start_date
      go_back_one_month
      export_workouts
    end
  end

  def export_current_month
    puts "processing #{current_date}"
    puts workouts.map(&:text).join("\n")
  end

  def workouts
    all(".fc-event")
  end

  def go_back_one_month
    find("#dashboard-calendar .fc-header-left .fc-button-prev .fc-text-arrow").click
  end

  def current_date
    find("#dashboard-calendar .fc-header-title").text
  end
end
