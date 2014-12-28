require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

class TSRScraper
  include Capybara::DSL

  def initialize(username, password, start_date)
    @username = username
    @password = password
    @start_date = start_date
    @workout_data = []

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.current_driver = :poltergeist
    Capybara.app_host = 'http://thesquatrack.com'
    Capybara.default_wait_time = 3
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
    puts @workout_data.flatten.join("\n")
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
    $stderr.puts "processing #{current_date}"
    workouts.each do |workout|
      export_workout(workout)
    end
  end

  def export_workout(workout, attempts = 0)
    select_workout workout
    select_export_format

    export_data.tap do |data|
      if !/^"Performed At"/.match(export_data)
        if attempts < 20
          return export_workout(workout, attempts+1)
        else
          save_and_open_screenshot
          raise "Couldn't get correct workout export format, got #{data} instead"
        end
      end

      @workout_data.push data.split("\n")
    end
  end

  def export_data
    find('.export_output textarea').value
  end

  def select_export_format
    open_export_format_selection
    find("ul.export_format_id li a", text: "CSV").click
    sleep 1
  end

  def select_workout(workout)
    workout.click
  end

  def open_export_format_selection
    find("#foundWorkouts .dropdown-toggle").trigger(:click)
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
