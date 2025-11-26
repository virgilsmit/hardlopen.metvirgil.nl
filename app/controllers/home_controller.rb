class HomeController < ApplicationController
  layout :determine_layout
  def index
    if current_user
      today = Date.today
      @upcoming_birthdays = User.where.not(birthday: nil).sort_by do |user|
        bday = user.birthday.change(year: today.year)
        bday < today ? bday.next_year : bday
      end.first(3)
      # Dynamische tegels uit tegelbeheer
      @tiles = helpers.visible_tiles_for_dashboard(current_user)

      # Voeg dynamische beschrijving toe aan verjaardagen-tegel
      today = Date.today
      upcoming_30 = User.where.not(birthday: nil).select do |u|
        bday = u.birthday.change(year: today.year)
        bday += 1.year if bday < today
        (bday - today).to_i <= 30
      end.sort_by { |u| u.birthday.change(year: today.year) }

      @tiles.each do |t|
        if t[:key] == 'birthdays_30'
          t[:desc] = upcoming_30.map { |u|
            d = u.birthday.change(year: today.year)
            d += 1.year if d < today
            "#{u.name.split.first} (#{d.strftime('%d-%m')})"
          }.first(5).join(', ') +
              ""
        end
      end
    else
      @upcoming_birthdays = []
    end

    @upcoming_public_sessions = TrainingSession.where('date >= ?', Date.today)
                                               .order(:date)
                                               .limit(8)
  end

  def prototype
    @proof_stats = [
      { label: 'Trainingen begeleid', value: '2.300+' },
      { label: 'Lopers actief', value: '180+' },
      { label: 'Motivatie behouden', value: '97%' }
    ]

    @benefits = [
      { title: 'Plan op maat', body: 'Schema’s afgestemd op tempozones, levensstijl en persoonlijke doelen zodat je progressie meetbaar blijft.' },
      { title: 'Techniek & feedback', body: 'Hands-on coaching tijdens sessies, video-analyse en directe bijsturing voor efficiënte loopstijl.' },
      { title: 'Data-inzicht', body: 'Structuurkern, zones en resultaten overzichtelijk in de app, inclusief historie en evaluaties.' },
      { title: 'Community drive', body: 'Train in een hechte groep die elkaar motiveert met gezamenlijke doelen en events.' }
    ]

    @programmes = [
      { title: 'Groepstraining', price: '€45 / maand', features: ['2 vaste sessies per week', 'Progressiecheck per kwartaal', 'Community events'] },
      { title: '1-op-1 traject', price: 'Op aanvraag', features: ['Intake + testloop', 'Schema per microcycle', 'Wekelijkse opvolging'] },
      { title: 'Wedstrijdvoorbereiding', price: '€199 / 8 weken', features: ['Specifieke wedstrijdplanning', 'Race day-strategie', 'Resultaatanalyse'] }
    ]

    @timeline_steps = [
      { title: 'Intake & doelen', body: 'Online intake + testloop om trainingszones en doelstellingen scherp te krijgen.' },
      { title: 'Plan opstellen', body: 'Periodisering en kerntrainingen afgestemd op je beschikbaarheid en wedstrijdagenda.' },
      { title: 'Sessies & feedback', body: 'Loop mee met de groep of 1-op-1 sessies; elke training sluit af met scherpe feedback.' },
      { title: 'Evaluatie & next', body: 'Maandelijkse check-in, datareview en bijstelling zodat je scherp blijft.' }
    ]

    @testimonials = [
      { quote: 'Ik liep binnen drie maanden mijn 10 km PR. De sessies zijn technisch én gezellig.', name: 'Nathalie • 10 km -2:14 min' },
      { quote: 'Virgil houdt overzicht over mijn schema terwijl ik druk ben met werk. Dat geeft rust.', name: 'Michel • halve marathon -5:32 min' },
      { quote: 'De community motiveert enorm. Elke training voelt als een stap dichterbij mijn doel.', name: 'Sara • consistent sinds 2022' }
    ]
  end

  def prototype_info
    schedule_path = Rails.root.join('app', 'Imports', 'GACABSchemaNajaar2025.csv')
    parsed = TrainingScheduleParser.call(schedule_path)
    @weeks = parsed[:weeks]
    @upcoming_sessions = parsed[:upcoming].first(8)
    @races = parsed[:races]

    @phases = @weeks.flat_map do |week|
      week[:entries].map(&:phase)
    end.compact.uniq
  end

  def prototype_track
    prototype_info
  end

  private

  def determine_layout
    case action_name
    when 'prototype_info'
      'prototype_info'
    when 'prototype_track'
      'prototype_track'
    else
      'application'
    end
  end
end
