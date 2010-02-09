module EventsHelper
  def attendee_icon attendee
    attendee.status ? icon_tag('lightbulb', :title => _('Attendance')) : icon_tag('cross', :title => _('Absence'))
  end
end
