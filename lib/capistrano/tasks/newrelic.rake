namespace :newrelic do
  desc 'Notify New Relic of deployment'
  task :notify do
    if fetch(:new_relic_enabled)
      run_locally do
        current_rev = fetch(:current_revision)
        previous_rev = fetch(:previous_revision)
        deployment = {
          :deployment => {
            :app_name => fetch(:new_relic_app_name) || fetch(:application),
            :description => "Deploy #{fetch(:application)}/#{fetch(:branch)} to #{fetch(:stage)}",
            :user => fetch(:git_user, nil),
            :revision => current_rev,
            :changelog => fetch(:git_changelog, nil)
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

end

namespace :deploy do
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
