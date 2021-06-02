# frozen_string_literal: true

module DashRubocop
  # Contains method to generate required assets
  module Assets
    def download_rubocop_tarball
      puts ">> Downloading RuboCop #{@version}"
      system('curl', '-Ls', '-o', '_output/rubocop.tgz',
             "https://github.com/rubocop-hq/rubocop/archive/v#{@version}.tar.gz")
      system('tar', '-C', '_output', '-xzf', '_output/rubocop.tgz')
      # Remove tar file asap to avoid name clash after generation
      FileUtils.rm '_output/rubocop.tgz'
      FileUtils.mv "_output/rubocop-#{@version}", '_output/source'
    end

    def write_stylesheet
      puts '>> Write CSS file'
      css = <<~CSS
        body {
          background-color: #fcfcfc;
          font-family: sans-serif;
        }
        h1, h2, h3, h4 {
          font-family: serif;
        }
        table {
          border-collapse: collapse;
          border-spacing: 0;
          empty-cells: show;
          max-width: 100%;
          font-size: 90%;
        }
        table td, table th {
          margin: 0;
          overflow: visible;
          padding: 8px 16px;
          border: 1px solid #e1e4e5;
          border-collapse: collapse;
          vertical-align: middle;
        }
        table td {
          background-color: transparent;
        }
        table tr:nth-child(2n-1) td {
          background-color: #f3f6f6;
        }
        code {
          background: #ffffff;
          border: solid 1px #e1e4e5;
          color: #e74c3c;
          padding: 2px 5px;
        }
        pre code {
          white-space: pre;
          word-wrap: normal;
          display: block;
          padding: 12px;
          color: #000000;
        }
        a {
          color: #2980b9;
          text-decoration: none;
        }
        a:hover {
          color: #3091d1;
          outline: 0;
        }
        a:visited {
          color: #9b59b6;
        }
        .highlight .hll { background-color: #ffffcc }
        .highlight .c { color: #999988; font-style: italic } /* Comment */
        .highlight .err { color: #a61717; background-color: #e3d2d2 } /* Error */
        .highlight .k { color: #000000; font-weight: bold } /* Keyword */
        .highlight .o { color: #000000; font-weight: bold } /* Operator */
        .highlight .cm { color: #999988; font-style: italic } /* Comment.Multiline */
        .highlight .cp { color: #999999; font-weight: bold; font-style: italic } /* Comment.Preproc */
        .highlight .c1 { color: #999988; font-style: italic } /* Comment.Single */
        .highlight .cs { color: #999999; font-weight: bold; font-style: italic } /* Comment.Special */
        .highlight .gd { color: #000000; background-color: #ffdddd } /* Generic.Deleted */
        .highlight .ge { color: #000000; font-style: italic } /* Generic.Emph */
        .highlight .gr { color: #aa0000 } /* Generic.Error */
        .highlight .gh { color: #999999 } /* Generic.Heading */
        .highlight .gi { color: #000000; background-color: #ddffdd } /* Generic.Inserted */
        .highlight .go { color: #888888 } /* Generic.Output */
        .highlight .gp { color: #555555 } /* Generic.Prompt */
        .highlight .gs { font-weight: bold } /* Generic.Strong */
        .highlight .gu { color: #aaaaaa } /* Generic.Subheading */
        .highlight .gt { color: #aa0000 } /* Generic.Traceback */
        .highlight .kc { color: #000000; font-weight: bold } /* Keyword.Constant */
        .highlight .kd { color: #000000; font-weight: bold } /* Keyword.Declaration */
        .highlight .kn { color: #000000; font-weight: bold } /* Keyword.Namespace */
        .highlight .kp { color: #000000; font-weight: bold } /* Keyword.Pseudo */
        .highlight .kr { color: #000000; font-weight: bold } /* Keyword.Reserved */
        .highlight .kt { color: #445588; font-weight: bold } /* Keyword.Type */
        .highlight .m { color: #009999 } /* Literal.Number */
        .highlight .s { color: #d01040 } /* Literal.String */
        .highlight .na { color: #008080 } /* Name.Attribute */
        .highlight .nb { color: #0086B3 } /* Name.Builtin */
        .highlight .nc { color: #445588; font-weight: bold } /* Name.Class */
        .highlight .no { color: #008080 } /* Name.Constant */
        .highlight .nd { color: #3c5d5d; font-weight: bold } /* Name.Decorator */
        .highlight .ni { color: #800080 } /* Name.Entity */
        .highlight .ne { color: #990000; font-weight: bold } /* Name.Exception */
        .highlight .nf { color: #990000; font-weight: bold } /* Name.Function */
        .highlight .nl { color: #990000; font-weight: bold } /* Name.Label */
        .highlight .nn { color: #445588; font-weight: bold } /* Name.Namespace */
        .highlight .nt { color: #000080 } /* Name.Tag */
        .highlight .nv { color: #008080 } /* Name.Variable */
        .highlight .ow { color: #000000; font-weight: bold } /* Operator.Word */
        .highlight .w { color: #bbbbbb } /* Text.Whitespace */
        .highlight .mf { color: #009999 } /* Literal.Number.Float */
        .highlight .mh { color: #009999 } /* Literal.Number.Hex */
        .highlight .mi { color: #009999 } /* Literal.Number.Integer */
        .highlight .mo { color: #009999 } /* Literal.Number.Oct */
        .highlight .sb { color: #d01040 } /* Literal.String.Backtick */
        .highlight .sc { color: #d01040 } /* Literal.String.Char */
        .highlight .sd { color: #d01040 } /* Literal.String.Doc */
        .highlight .s2 { color: #d01040 } /* Literal.String.Double */
        .highlight .se { color: #d01040 } /* Literal.String.Escape */
        .highlight .sh { color: #d01040 } /* Literal.String.Heredoc */
        .highlight .si { color: #d01040 } /* Literal.String.Interpol */
        .highlight .sx { color: #d01040 } /* Literal.String.Other */
        .highlight .sr { color: #009926 } /* Literal.String.Regex */
        .highlight .s1 { color: #d01040 } /* Literal.String.Single */
        .highlight .ss { color: #990073 } /* Literal.String.Symbol */
        .highlight .bp { color: #999999 } /* Name.Builtin.Pseudo */
        .highlight .vc { color: #008080 } /* Name.Variable.Class */
        .highlight .vg { color: #008080 } /* Name.Variable.Global */
        .highlight .vi { color: #008080 } /* Name.Variable.Instance */
        .highlight .il { color: #009999 } /* Literal.Number.Integer.Long */
      CSS
      IO.write "#{@outdir}/Documents/theme.css", css
    end

    def write_main_plist
      puts '>> Write plist file'
      plist = <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleIdentifier</key>
          <string>rubocop</string>
          <key>CFBundleName</key>
          <string>RuboCop</string>
          <key>DocSetPlatformFamily</key>
          <string>rubocop</string>
          <key>isDashDocset</key>
          <true/>
          <key>DashDocSetFamily</key>
          <string>dashtoc</string>
          <key>dashIndexFilePath</key>
          <string>index.html</string>
        </dict>
        </plist>
      PLIST
      IO.write('_output/RuboCop.docset/Contents/Info.plist', plist)
    end

    def write_main_meta_file
      puts '>> Write meta file'
      IO.write(
        '_output/RuboCop.docset/meta.json',
        JSON.pretty_generate(
          { name: 'RuboCop', version: @version, title: 'RuboCop' }
        )
      )
    end

    def write_required_assets
      write_stylesheet
      write_main_plist
      write_main_meta_file
    end

    def write_docset_json_file
      puts '>> Write docset.json file'
      meta = {
        name: 'RuboCop',
        version: @version,
        archive: 'RuboCop.tgz',
        author: {
          name: 'Étienne Deparis',
          link: 'https://etienne.depar.is'
        },
        aliases: %w[Rubocop rubocop]
      }
      old_meta = JSON.parse(IO.read("#{@dash_root}/docset.json"))
      old_versions = old_meta['specific_versions'] || []
      has_current = old_versions.index { |v| v['version'] == @version }
      if has_current.nil?
        old_versions.unshift({ version: @version,
                               archive: "versions/#{@version}/RuboCop.tgz" })
      end
      meta['specific_versions'] = old_versions
      IO.write "#{@dash_root}/docset.json", JSON.pretty_generate(meta)
    end

    def convert_and_copy_icons
      puts '>> Convert and copy icons'
      unless File.exist? "#{@dash_root}/icon.png"
        system('convert', '_output/source/logo/rubo-logo-symbol.png',
               '-resize', '16x16', '_output/RuboCop.docset/icon.png')
        FileUtils.cp '_output/RuboCop.docset/icon.png',
                     "#{@dash_root}/icon.png"
      end
      return if File.exist? "#{@dash_root}/icon@2x.png"
      system('convert', '_output/source/logo/rubo-logo-symbol.png',
             '-resize', '32x32', '_output/RuboCop.docset/icon@2x.png')
      FileUtils.cp '_output/RuboCop.docset/icon@2x.png',
                   "#{@dash_root}/icon@2x.png"
    end

    def generate_tarball
      convert_and_copy_icons
      write_docset_json_file
      puts '>> Generating tarball'
      system('tar', '-C', '_output', '--exclude', '.DS_Store', '-czf',
             "#{@dash_root}/RuboCop.tgz", 'RuboCop.docset')
      FileUtils.mkdir_p("#{@dash_root}/versions/#{@version}")
      FileUtils.cp "#{@dash_root}/RuboCop.tgz",
                   "#{@dash_root}/versions/#{@version}/RuboCop.tgz"
    end
  end
end
