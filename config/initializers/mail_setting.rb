ActionMailer::Base.raise_delivery_errors = GlobalInitialSetting['raise_delivery_errors']

ActionMailer::Base.smtp_settings = GlobalInitialSetting['exception_notifier']['smtp_settings']
