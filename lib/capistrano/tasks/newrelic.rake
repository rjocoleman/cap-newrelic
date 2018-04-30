namespace :newrelic do
  desc 'Notify New Relic of deployment'
  task :notify do
    if fetch(:new_relic_enabled) and fetch(:new_relic_app_name)
      run_locally do
        local_user = capture('git config user.name').strip
        current_rev = fetch(:current_revision)
        changelog = fetch(:changelog)
        deployment = {
          :deployment => {
            :app_name => fetch(:new_relic_app_name),
            :description => "Deploy #{fetch(:application)}/#{fetch(:branch)} to #{fetch(:stage)}",
            :user => local_user,
            :revision => current_rev,
            :changelog => changelog
          }
        }
        new_relic_api_key = fetch(:new_relic_api_key) || ENV['NEW_RELIC_API_KEY']
        fail ":new_relic_api_key must be set - \"set :new_relic_api_key, 'yourkey'\"" unless new_relic_api_key
        response = Faraday.post do |req|
          req.url fetch(:new_relic_url)
          req.headers['x-api-key'] = new_relic_api_key
          req.body = deployment
        end
        if response.headers['status'] =~ /201/
          info "[New Relic] Deployment created."
        else
          error = REXML::XPath.each(REXML::Document.new(response.body), "*/error/text()").first
          info "[New Relic] #{response.headers['status']} - #{error}"
        end
      end
    end
  end

  task :set_changelog do
    run_locally do
      current_rev = fetch(:branch)
      previous_rev = fetch(:previous_revision)

      begin
        set(:changelog, capture("git log --oneline #{previous_rev}..#{current_rev}"))
      rescue
        raise("Could not get changelog, you probably need to pull master!")
      end
    end
  end
end

namespace :deploy do
  after :starting, 'newrelic:set_changelog'
  after :finished, 'newrelic:notify'
end

namespace :load do
  task :defaults do
    set :new_relic_api_key, nil
    set :new_relic_app_name, fetch(:application)
    set :new_relic_url, 'https://api.newrelic.com/deployments.xml'
    set :new_relic_enabled, true
  end
end
