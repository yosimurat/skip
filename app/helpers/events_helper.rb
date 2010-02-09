module EventsHelper
  def attendee_icon attendee
    attendee.status ? icon_tag('lightbulb', :title => _('Attendance')) : icon_tag('cross', :title => _('Absence'))
  end

  def event_type_icon event
    icon_tag('key', :title => _('Need invitation of the Administrator')) if event.publication_type == 'protected'
  end
end
