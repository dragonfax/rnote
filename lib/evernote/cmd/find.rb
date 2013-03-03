
require 'rnote/find'

include GLI::App


desc 'search for notes/tags/notebooks'
command :find do |verb|

  verb.command :note do |noun|

    noun.desc "don't hit the api, just show the last search results"
    noun.switch :cached

    Rnote::Find.include_search_options(noun)

    noun.action do |global_options,options,args|

      find = Rnote::Find.new($app.auth,$app.persister)

      if options[:cached]

        raise "Can't take any other search arguments with --cached" if args.length > 0

        find.display_results($app.persister.get_last_results)

      else

        find.find_cmd(options,args)

      end

    end
  end
end

