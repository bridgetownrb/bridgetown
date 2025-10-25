# frozen_string_literal: true

require "helper"

class TestLiquidRenderer < BridgetownUnitTest
  describe "profiler" do
    before do
      @site = Site.new(site_configuration)
      @renderer = @site.liquid_renderer
    end

    it "returns a table with profiling results" do
      @site.process

      output = @renderer.stats_table

      expected = [
        %r!^\| Filename\s+|\s+Count\s+|\s+Bytes\s+|\s+Time$!,
        %r!^\+(?:-+\+){4}$!,
        %r!^\|_posts/2010-01-09-date-override\.markdown\s+|\s+\d+\s+|\s+\d+\.\d{2}K\s+|\s+\d+\.\d{3}$!,
      ]

      expected.each do |regexp|
        assert_match regexp, output
      end
    end
  end
end
