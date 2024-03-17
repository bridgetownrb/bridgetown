FROM gitpod/workspace-full
USER gitpod

# Define Ruby version
ENV RUBY_VERSION=3.1.4
ENV RUBY_WEBSITE_VERSION=3.1.4

# Install the required Ruby version and set it as default
RUN echo "rvm_gems_path=/home/gitpod/.rvm" > ~/.rvmrc
RUN bash -lc "rvm install ruby-$RUBY_WEBSITE_VERSION"
RUN bash -lc "rvm install ruby-$RUBY_VERSION && rvm use ruby-$RUBY_VERSION --default"
RUN echo "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc