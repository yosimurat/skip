if GlobalInitialSetting['exception_notifier']['enable']
  # exception_notifier
  ExceptionNotifier.exception_recipients = %(#{GlobalInitialSetting['administrator_addr']})
  # defaults to exception.notifier@default.com
  ExceptionNotifier.sender_address = %(#{GlobalInitialSetting['exception_notifier']['sender_addr']})
  # defaults to "[ERROR] "
  ExceptionNotifier.email_prefix = GlobalInitialSetting['exception_notifier']['email_prefix'] || "[ERROR] "
end
