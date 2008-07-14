require 'fs_event/stream'

module FSEvent
  class Listener
    def initialize(*paths)
      @stream = FSEvent::Stream.new(paths) do |stream, ctx, num_events, paths, marks, event_ids|
        puts "#{stream}, #{ctx}, #{num_events}, #{paths}, #{marks}, #{event_ids}"
      end
    end

    def start
      @stream.schedule
      @stream.start
    end

    def stop
      @stream.stop
      @stream.invalidate
      @stream.release
    end
  end
end