# Pull in the Ruby Cocoa Framework.
require 'osx/foundation'  
OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'

module FSEvent
  class Stream
    def initialize(paths, &block)
      @stream = OSX::FSEventStreamCreate(
        OSX::KCFAllocatorDefault,
        block,
        nil,
        Array[*paths],
        OSX::KFSEventStreamEventIdSinceNow,
        1.0,  # latency
        0     # flags
      )
    end
    
    def schedule
      OSX::FSEventStreamScheduleWithRunLoop(@stream, OSX::CFRunLoopGetCurrent(), OSX::KCFRunLoopDefaultMode) unless @stream.nil?
    end
    
    def start
      OSX::FSEventStreamStart(@stream) unless @stream.nil?
    end
    
    def stop
      OSX::FSEventStreamStop(@stream) unless @stream.nil?
    end
    
    def invalidate
      OSX::FSEventStreamInvalidate(@stream) unless @stream.nil?
    end
    
    def release
      OSX::FSEventStreamRelease(@stream) unless @stream.nil?
      @stream = nil
    end
  end
end
