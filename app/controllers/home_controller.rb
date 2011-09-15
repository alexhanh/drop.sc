class HomeController < ApplicationController
  def index
    @patches = Replay.public.processed.select("DISTINCT(replays.version)").order("replays.version DESC")

    @tmp = @patches.first
    unless @tmp.nil?
      @latest_patch = @patches.first.version
      @latest_patch = @patches.second.version if @latest_patch.nil?
    end
    
    @events = Event.order("begins DESC").limit(5)
  end
end