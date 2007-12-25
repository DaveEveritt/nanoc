require 'test/unit'

require File.join(File.dirname(__FILE__), 'helper.rb')

class FilterBlueClothTest < Test::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  def test_filter
    if_have 'bluecloth' do
      assert_nothing_raised do
        with_site_fixture 'empty_site' do |site|
          site.load_data

          # Get filter
          page  = site.pages.first.to_proxy
          pages = site.pages.map { |p| p.to_proxy }
          filter = ::Nanoc::Filter::BlueCloth::BlueClothFilter.new(page, pages, site.config, site)

          # Run filter
          result = filter.run("> Quote")
          assert_equal("<blockquote>\n    <p>Quote</p>\n</blockquote>", result)
        end
      end
    end
  end

end