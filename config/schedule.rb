every 1.day, at: '9:00 am' do
  runner "DailyTrendService.generate_and_notify_users"
end