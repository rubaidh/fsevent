class Autotest
  def run
    hook :run
    reset

    run_tests

    require 'osx/foundation'
    OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'

    callback = proc do |stream, ctx, numEvents, paths, marks, eventIDs|
      paths.regard_as('*')
      rpaths = []

      numEvents.times { |i| rpaths << paths[i] }

      run_tests_in_paths(*rpaths)
    end

    allocator = OSX::KCFAllocatorDefault
    context   = nil
    path      = [Dir.pwd]
    sinceWhen = OSX::KFSEventStreamEventIdSinceNow
    latency   = 1.0
    flags     = 0

    stream   = OSX::FSEventStreamCreate(allocator, callback, context, path, sinceWhen, latency, flags)
    unless stream
      puts "Failed to create stream"
      exit
    end

    OSX::FSEventStreamScheduleWithRunLoop(stream, OSX::CFRunLoopGetCurrent(), OSX::KCFRunLoopDefaultMode)
    unless OSX::FSEventStreamStart(stream)
      puts "Failed to start stream"
      exit 
    end

    OSX::CFRunLoopRun()
  rescue Interrupt
    OSX::FSEventStreamStop(stream)
    OSX::FSEventStreamInvalidate(stream)
    OSX::FSEventStreamRelease(stream)
  end

  def find_files_in_paths(*paths)
    current_dir = Dir.pwd.length + 1
    result = {}
    paths.each do |path|
      # Largely copied from autotest
      Find.find path do |f|
        Find.prune if @exceptions and f =~ @exceptions and test ?d, f
        next if test ?d, f
        next if f =~ /(swp|~|rej|orig)$/
        next if f =~ /\/\.?#/

        filename = f[current_dir..-1]
        result[filename] = File.stat(filename).mtime rescue next
      end
    end
    return result
  end

  def run_tests_in_paths(*paths)
    find_files_to_test(find_files_in_paths(*paths))
    return if @files_to_test.empty?
    # Copied from autotest
    cmd = make_test_cmd @files_to_test

    hook :run_command
    puts cmd

    old_sync = $stdout.sync
    $stdout.sync = true
    @results = []
    line = []
    begin
      open("| #{cmd}", "r") do |f|
        until f.eof? do
          c = f.getc
          putc c
          line << c
          if c == ?\n then
            @results << line.pack("c*")
            line.clear
          end
        end
      end
    ensure
      $stdout.sync = old_sync
    end
    hook :ran_command
    @results = @results.join

    handle_results(@results)
  end
end