class ApplyIndexCommand
  def initialize(options)
    @options = options
  end
  
  def perform
    validate_options!
    process_index_commits_dirs
  end
  
  private
  
  def process_index_commits_dirs
    glob_path = File.join(@options[:index_dir], 'c*/')
    git = Git.open(@options[:dst_prj_dir])
    Dir.glob(glob_path).each { |index_path| import_commit(git, index_path) }
    
    puts 'DONE.'
  end
  
  def import_commit(git, index_path)
    unless index_path.match(/c\d{8}_[a-f0-9]{10}_.*/)
      puts "WARN: skipping path as mismatched to the index-folder-template: #{index_path}"
      return
    end
    
    commit_info = JSON.parse(File.read(File.join(index_path, 'info.json')))
    message_file_path = File.join(index_path, 'message.txt')

    git.commit(
      nil, # we are specifying the commit message by :message_file_path option
      message_file_path: message_file_path,
      allow_empty: true, 
      date: format_date_for_git(commit_info['date']),
      author: "#{commit_info['author_name']} <#{commit_info['author_email']}>" 
    )
    
    print '.'
  end
  
  # From `man git-commit`:
  # 
  #   --date=<date>
  #            Override the author date used in the commit.    
  #   ...
  # 
  #   The GIT_AUTHOR_DATE, GIT_COMMITTER_DATE environment variables and the --date option support
  #        the following date formats:
  # 
  #        Git internal format
  #            It is <unix timestamp> <time zone offset>, where <unix timestamp> is the number of
  #            seconds since the UNIX epoch.  <time zone offset> is a positive or negative offset from
  #            UTC. For example CET (which is 1 hour ahead of UTC) is +0100.
  # 
  #        RFC 2822
  #            The standard email format as described by RFC 2822, for example Thu, 07 Apr 2005
  #            22:13:13 +0200.
  # 
  #        ISO 8601
  #            Time and date specified by the ISO 8601 standard, for example 2005-04-07T22:13:13. The
  #            parser accepts a space instead of the T character as well. Fractional parts of a second
  #            will be ignored, for example 2005-04-07T22:13:13.019 will be treated as
  #            2005-04-07T22:13:13.
  # 
  #                Note
  #                In addition, the date part is accepted in the following formats: YYYY.MM.DD,
  #                MM/DD/YYYY and DD.MM.YYYY.
  # 
  #
  # It means, `git commit --date=<...>` command accepts `DateTime.now.to_s` format
  def format_date_for_git(date)
    # When we were building index, we just got `DateTime`-object, which converted to String.
    # So we do not need any modification here. 
    # This method - is just for reference
    date
  end
  
  
  def dst_prj_in_clean_state?
    # TODO: instead of this dirty solution, create PR to the git gem (https://github.com/ruby-git/ruby-git)
    # if `git status -u -s` returns blank string -- it means, 
    # the git repository in the clean state (nothing changed)
    git = Git.open(@options[:dst_prj_dir])
    git.lib.send(:command, 'status -u -s').blank?  
  end
  
  def validate_options!
    raise "The '--dst_prj_dir' option is required for apply_index-command!" if @options[:dst_prj_dir].blank?
    raise "The '--index_dir' option is required for apply_index-command!" if @options[:index_dir].blank?

    unless Dir.exist?(File.join(@options[:dst_prj_dir], '.git'))
      raise "Looks like the specified --dst_prj_dir (#{@options[:dst_prj_dir]}) is not initialized with git yet!"
    end

    unless dst_prj_in_clean_state?
      raise "Looks, like --dst_prj_dir (#{@options[:dst_prj_dir]}) has uncommitted changes"
    end
  end
end
