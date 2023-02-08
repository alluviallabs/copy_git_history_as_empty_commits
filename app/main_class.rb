class MainClass
  def initialize(options)
    @options = options
  end
  
  def perform
    check_git_is_installed!
    validate_options!
    
    if @options[:command] == 'build_index'
      BuildIndexCommand.new(@options).perform
    elsif @options[:command] == 'apply_index'
      ApplyIndexCommand.new(@options).perform
    else
      raise "Unknown command #{@options[:command]}!"
    end
  end
  
  def check_git_is_installed!
    raise "Can't find the git. Please, install git first: https://git-scm.com" unless `git --version`.include? 'git version'
  end
  
  def validate_options!
    raise "The '--command' option is required!" if @options[:command].blank?
  end
end
