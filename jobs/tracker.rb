require 'json'
require 'pivotal-tracker'

class Tracker
  def initialize(project_id, user_token, *user_name)
    @project_id, @user_name = project_id, user_name.join(" ")
    PivotalTracker::Client.token = user_token
  end

  def latest_status
    project = PivotalTracker::Project.find(@project_id)
    project_view = TrackerProjectView.new(project, @user_name)
    TrackerStatus.new(project_view)
  end
end

class TrackerStatus
  def initialize(project_view)
    @project_view = project_view
  end

  def passing?
    @project_view.rejected_stories.empty?
  end

  def pending?
    @project_view.started_stories.empty? && \
      @project_view.rejected_stories.empty?
  end
end

class TrackerProjectView
  def initialize(project, user_name)
    @project, @user_name = project, user_name
  end

  def started_stories;  stories_marked_as(:started);  end
  def rejected_stories; stories_marked_as(:rejected); end

  private

  def owned_stories
    @owned_stories ||= @project.stories.all(:owned_by => @user_name)
  end

  def stories_marked_as(state)
    owned_stories.select { |s| s.current_state == state.to_s }
  end
end

class TrackerConfig
  attr_accessor :token

  def self.read
    @config ||= YAML.load(
      ERB.new(
        File.read('config/tracker.yml')
      ).result(TrackerConfig.new.get_binding)
    )
  end

  def initialize
    @token = ENV['288cf81cb68c18f634d1314077dccebb']
  end

  def get_binding
    binding()
  end
end