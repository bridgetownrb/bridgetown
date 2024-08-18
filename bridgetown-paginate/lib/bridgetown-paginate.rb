# frozen_string_literal: true

#################################################
# Special thanks to Sverrir Sigmundarson and the
# contributors to Jekyll::Paginate V2 for the
# basis of this gem.
# https://github.com/sverrirs/jekyll-paginate-v2
#################################################

require "bridgetown-core"

module Bridgetown
  module Paginate
  end
end

require "bridgetown-paginate/defaults"
require "bridgetown-paginate/utils"
require "bridgetown-paginate/hooks"
require "bridgetown-paginate/pagination_indexer"
require "bridgetown-paginate/paginator"
require "bridgetown-paginate/pagination_page"
require "bridgetown-paginate/pagination_model"
require "bridgetown-paginate/pagination_generator"
