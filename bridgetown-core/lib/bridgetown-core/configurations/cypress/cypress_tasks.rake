namespace :cy do
  task :open do
    system "yarn run cypress open"
  end

  task :test do
    server_pid = fork { Bridgetown::Commands::Start.start }
    system "yarn run cypress open"
    Process.kill "SIGTERM", server_pid
  end

  task :run do
    system "yarn run cypress run"
  end

  namespace :test do
    task :ci do
      server_pid = fork { Bridgetown::Commands::Start.start }
      system "yarn run cypress run"
      Process.kill "SIGTERM", server_pid
    end
  end
end
