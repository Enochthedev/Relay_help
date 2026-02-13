namespace :widget_keys do
  desc "Backfill widget keys from workspace legacy columns"
  task backfill: :environment do
    puts "Starting backfill of widget keys..."
    Workspace.find_each do |w|
      next unless w.widget_api_key
      
      # Check if key already exists (by public key) to avoid duplicates
      if WidgetKey.exists?(public_key: w.widget_api_key)
        puts "Key already exists for #{w.name}"
        next
      end
      
      puts "Backfilling key for #{w.name}"
      begin
        w.widget_keys.create!(
          public_key: w.widget_api_key,
          secret_key: w.widget_secret_key || SecureRandom.hex(32),
          label: "Legacy Key",
          allowed_domains: w.allowed_domains || [],
          status: "active"
        )
      rescue => e
        puts "Error creating key for #{w.name}: #{e.message}"
      end
    end
    puts "Done. Total keys: #{WidgetKey.count}"
  end
end
