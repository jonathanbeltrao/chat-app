# Start the user cleanup job when Rails starts
Rails.application.config.after_initialize do
  # Only start the job in production or if explicitly enabled
  if Rails.env.production? || ENV['ENABLE_USER_CLEANUP'] == 'true'
    UserCleanupJob.perform_later
  end
end
