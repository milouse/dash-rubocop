# frozen_string_literal: true

module DashRubocop
  # Contains method to generate help files content
  module Contents
    # rubocop:disable Layout/LineLength
    def generate_database
      puts '>> Create db file'
      db = SQLite3::Database.new "#{@outdir}/docSet.dsidx"
      db.execute('CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);')
      db.execute('CREATE UNIQUE INDEX IF NOT EXISTS anchor ON searchIndex (name, type, path);')
      db
    end
    # rubocop:enable Layout/LineLength

    def entry_type(tag_name, html_file)
      if html_file.start_with?('cops_')
        return 'Category' if tag_name == 'h1'

        return 'Test'
      end
      return 'Guide' if tag_name == 'h1'

      'Section'
    end

    def uri_for_subtitles(html_file, entry, tag)
      attr = "//apple_ref/cpp/#{entry}/#{CGI.escape(tag.content)}"
      tag.add_previous_sibling(%(<a name="#{attr}" class="dashAnchor"></a>))
      "#{html_file}##{tag.attribute('id').value}"
    end

    def insert_tag(tag, html_file, entry = nil)
      entry = entry_type(tag.name, html_file) if entry.nil?
      if tag.name == 'h1'
        uri = html_file
      else
        # For h2 and h3
        uri = uri_for_subtitles(html_file, entry, tag)
      end
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        tag.content, entry, uri
      )
    end

    def extract_h3s(doc, basename, html_file)
      settings = %w[Enabled Severity Details AutoCorrect]
      doc.css('h3[id]').each do |tag|
        if basename == 'configuration' && settings.include?(tag.content)
          insert_tag(tag, html_file, 'Setting')
        else
          insert_tag(tag, html_file)
        end
      end
    end

    def write_to_target(doc, html_file)
      target_file = File.join(@outdir, 'Documents', html_file)
      target_dir = File.dirname(target_file)
      FileUtils.mkdir_p(target_dir) unless Dir.exist?(target_dir)
      IO.write(target_file, doc.to_html)
    end

    def extract_basename_and_html_file(adoc)
      path, file = File.split(adoc)
      basename = File.basename(file, '.adoc')
      html_file = "#{basename}.html"
      if path != '_output/source/docs/modules/ROOT/pages'
        html_file = File.join(
          path.delete_prefix('_output/source/docs/modules/ROOT/pages/'),
          html_file
        )
      end
      [basename, html_file]
    end

    # rubocop:disable Layout/LineLength
    def add_missing_references
      puts '>> Add supplementary settings from various files'
      [
        { label: 'Include', id: 'includingexcluding_files' },
        { label: 'Exclude', id: 'includingexcluding_files' },
        { label: 'TargetRubyVersion', id: 'setting_the_target_ruby_version' },
        { label: 'StyleGuideBaseURL', id: 'setting_the_style_guide_url' },
        { label: 'StyleGuide', id: 'setting_the_style_guide_url' },
        { label: 'inherit_from', id: 'inheriting_from_another_configuration_file_in_the_project' },
        { label: 'inherit_gem', id: 'inheriting_configuration_from_a_dependency_gem' }
      ].each do |s|
        if s.is_a? String
          attr = s.downcase
        else
          attr = s[:id]
          s = s[:label]
        end
        @db.execute(
          'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
          s, 'Setting', "configuration.html##{attr}"
        )
      end
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'NewCops', 'Setting', 'versioning.html#pending_cops'
      )
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'require', 'Setting', 'extensions.html#loading_extensions'
      )
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'UseCache', 'Setting', 'usage/caching.html#enabling_and_disabling_the_cache'
      )
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'CacheRootDirectory', 'Setting', 'usage/caching.html#cache_path'
      )
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'MaxFilesInCache', 'Setting', 'usage/caching.html#cache_pruning'
      )
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'Safe', 'Setting', 'usage/auto_correct.html#safe_auto_correct'
      )
      @db.execute(
        'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?);',
        'SafeAutoCorrect', 'Setting', 'usage/auto_correct.html#safe_auto_correct'
      )
    end
    # rubocop:enable Layout/LineLength

    def convert_adoc_to_html(adoc)
      basename, html_file = extract_basename_and_html_file(adoc)
      puts ">> Converting #{adoc} to #{html_file}"

      source = IO.read(adoc)
      html = Asciidoctor.convert(
        source,
        header_footer: true,
        attributes: %w[source-highlighter=rouge stylesheet=theme.css idprefix]
      )
      # rubocop:disable Layout/LineLength
      html.sub!('<html lang="en">', "<html><!-- Online page at https://docs.rubocop.org/rubocop/#{@version.sub(/\.0$/, '')}/#{html_file} -->")
      # rubocop:enable Layout/LineLength
      doc = Nokogiri::HTML(html)
      doc.css('title').first.add_next_sibling(
        '<link rel="shortcut icon" type="image/png" href="../../../icon.png">'
      )

      doc.css('h1,h2[id]').each do |tag|
        insert_tag(tag, html_file)
      end

      extract_h3s(doc, basename, html_file) unless basename.start_with?('cops_')

      write_to_target(doc, html_file)
    end
  end
end
