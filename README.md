# copy_git_history_as_empty_commits

Allows you to "copy" blank git commits to a collapsed project 
in order to save the history of commits messages.

Let's say you have a private git repository with a lot of corporate stuff in it. 
Let's say you want to make this project opensource.

You will need to cleanup the private corporate stuff, but at the same time, 
you would like to leave a semblance of git-history.

There couple ways to do this: 

* in case you want to preserve whole history, see these tools: 
  * (git-filter-branch and git-rebase)[https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History]
  * (git-filter-repo)[https://github.com/newren/git-filter-repo/]
  * (bfg-repo-cleaner)[https://rtyley.github.io/bfg-repo-cleaner/]
* in case you want to take just source code, and preserve only git-commit messages (without actual code deltas),
  you can use this tool. 


# First run (with installed ruby)

    cd /home/alex/prj/
    git clone https://github.com/alluviallabs/copy_git_history_as_empty_commits.git
    cd copy_git_history_as_empty_commits/
    rvm use .                       # https://rvm.io/
    gem install bundler:2.3.14
    bundle install
    ruby run.rb --help

# First run (with docker)

TODO: write instruction for docker
   
 
# Usage example:
 
First, go to your real git-repository and create copy of your project without git history:   

    cd /home/alex/prj/private_project
    private_project:$       mkdir ../public_project_copy
    private_project:$       git archive master |tar -x -f - -C ../public_project_copy
   
    
Go to the new copy of your project and clean up your corporate stuff: 

    cd /home/alex/prj/public_project_copy/
    # <this is where cleaning and refactoring takes place>

After cleaning, you will need to initialize new blank git-database:
    
    cd /home/alex/prj/public_project_copy/    
    git init . 
    git add -A
    git commit -m 'First commit (collapsed history, forked from our private project)'

Now you can extract all your commits descriptions and commits statistics to be able modify or delete any of them:

    cd /home/alex/prj/copy_git_history_as_empty_commits/
    mkdir -p './tmp/commits_index_dir'
    
    ruby run.rb \ 
      --command build_index \
      --src_prj_dir '/home/alex/prj/private_project' \
      --index_dir './tmp/commits_index_dir' \
      --msg_prefix '[BLANK_COMMIT] ' \
      --msg_postfix "This commit was generated automatically, by \
        https://github.com/alluviallabs/copy_git_history_as_empty_commits"
      
Now, in the folder `./tmp/commits_index_dir` you will see extracted history index:

    ls -l ./tmp/commits_index_dir
      
        0001911_<sha_1911>_john_smith/
        ...
        0000002_<sha_2>_vasya_pupkin/
        0000001_<sha_1>_john_smith/  

Inside of the folder `0000001_<sha_1>_john_smith/`, there will be two files:        
        
        ./message.txt    # commit message
        ./info.json      # parsed commit information
        
After index was built, using your favorite IDE or text-editor, you can: 

* delete any of commits
  * these deleted commits will not be copied on the new project
* change commit descriptions in `message.txt`-files
* change any parsed data in `info.json`-files  


After you have finished editing files in the `--index_dir`, 
you can apply the new git history to the new project:
 
    cd /home/alex/prj/copy_git_history_as_empty_commits/
    ruby run.rb \ 
      --command apply_index \
      --index_dir './tmp/commits_index_dir' \
      --new_prj_dir '/home/alex/prj/public_project_copy'
     
This command: 
 
* will init new .git repository in the `--new_prj_dir` folder.
* will take all commits-messages from  `--index_dir` folder 
  and apply them as blank commits (see [`git commit --allow-empty`][git_commit_allow_empty] option for reference) 

[git_commit_allow_empty]: https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---allow-empty

For safety reason, this command will fail, if there will be `.git`-database 
in the `--new_prj_dir` folder.  You can turn off this fuse 
by passing `--skip_git_initialization` option.   
