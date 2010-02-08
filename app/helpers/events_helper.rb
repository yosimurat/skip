module EventsHelper
  def attendee_icon attendee
    case attendee.status
    when 'attend' then icon_tag('lightbulb', :title => _('Attendance'))
    when 'absent' then icon_tag('cross', :title => _('Absence'))
    else ''
    end
  end
end
