# frozen_string_literal: true

require 'json'
require 'sqlite3'
require 'nokogiri'
require 'fileutils'
require 'asciidoctor'
require 'dash_rubocop/assets'
require 'dash_rubocop/contents'

module DashRubocop
  # Main app
  class Converter
    def initialize(version)
      @version = version
      FileUtils.rm_r '_output' if Dir.exist? '_output'
      @outdir = '_output/RuboCop.docset/Contents/Resources'
      FileUtils.mkdir_p "#{@outdir}/Documents"
      @dash_root = 'Dash-User-Contributions/docsets/RuboCop'
      exit unless Dir.exist? @dash_root
    end

    def run
      download_rubocop_tarball
      write_required_assets
      @db = generate_database

      # rubocop:disable Layout/LineLength
      Dir.glob('_output/source/docs/modules/ROOT/pages/**/*.adoc').each do |adoc|
        convert_adoc_to_html(adoc)
      end
      # rubocop:enable Layout/LineLength

      add_missing_references
      generate_tarball
    end

    include DashRubocop::Assets
    include DashRubocop::Contents
  end
end

if ARGV.length != 1
  warn 'Please specify the rubocop target tag'
  exit 1
end

DashRubocop::Converter.new(ARGV[0]).run
