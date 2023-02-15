class BuildIndexCommand
  def initialize(options)
    @options = options
  end
  
  def perform
    validate_options!
    build!
  end
  
  private
  
  def build!
    working_dir = @options[:src_prj_dir]
    git = Git.open(working_dir)
    git_history = git.log(nil)
    git_history.reverse_each.with_index do |commit, idx|
      build_commit(commit, idx)
    end
  end
  
  def commit_dir_name(commit, idx)
    sha = commit.sha[0..9]
    name = commit.author.name
             .strip
             .gsub(/\s+/, '_')         # Fist name and Last name can be separated more then 1 space
             .gsub(/[^a-zA-Z_]+/, '')  # will keep only english letters
    idx_str = "%08d" % idx
    "c#{idx_str}_#{sha}_#{name}"       # c = commit
  end
  
  def create_commit_dir(commit, idx)
    dir_name = commit_dir_name(commit, idx)
    dir_path = File.join(@options[:index_dir], dir_name)
    FileUtils.mkdir dir_path
    dir_path
  end
  
  def write_commit_message(commit, commit_dir_path)
    file_path = File.join(commit_dir_path, 'message.txt')
    File.open(file_path, 'w') do |f|
      message = commit.message
      message = @options[:msg_prefix] + message if @options[:msg_prefix].present?
      
      # Maybe you will want to place some extra code here, like: 
      # 
      #     message = message + "\n\n" + commit.diff_parent.to_s + "\n\n"           # real code deltas
      # 
      # or
      #   
      #     message = message + "\n\n" + commit.diff_parent.stats.to_s + "\n\n"     # commit statistics
      # 
      
      message = message + "\n\n" + @options[:msg_postfix] if @options[:msg_postfix].present? 
      
      message = message + "\n\n" + "[ORIGINAL_COMMIT_HASH: #{commit.sha}]\n" if @options[:do_include_original_sha] 
      
      f.write(message)
    end
  end

  def write_commit_info(commit, commit_dir_path)
    info = {}
    info[:sha] = commit.sha
    info[:author_name] = commit.author.name
    info[:author_email] = commit.author.email
    info[:date] = commit.date
    file_path = File.join(commit_dir_path, 'info.json')
    File.open(file_path, 'w') { |f| f.write(JSON.neat_generate(info)) }
  end
  
  def build_commit(commit, idx)
    if @options[:skip_merge_commits]
      return if commit.parents.count == 2
    end
    
    commit_dir_path = create_commit_dir(commit, idx)
    
    write_commit_info(commit, commit_dir_path)
    write_commit_message(commit, commit_dir_path)
  end

  def validate_options!
    raise "The '--src_prj_dir' option is required for build_index-command!" if @options[:src_prj_dir].blank?
    raise "The '--index_dir' option is required for build_index-command!" if @options[:index_dir].blank?

    raise "Directory --src_prj_dir (#{@options[:src_prj_dir]}) does not exists!" unless Dir.exist? @options[:src_prj_dir]
    
    raise "Directory --index_dir (#{@options[:index_dir]}) does not exists!" unless Dir.exist? @options[:index_dir]
    raise "Directory --index_dir (#{@options[:index_dir]}) is not empty!" unless Dir.empty? @options[:index_dir]
    
    unless Dir.exist?(File.join(@options[:src_prj_dir], '.git'))
      raise "Looks like the specified --dst_prj_dir (#{@options[:dst_prj_dir]}) is not initialized with git yet!"
    end
  end

end
