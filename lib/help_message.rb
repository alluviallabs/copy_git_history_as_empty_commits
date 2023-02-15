HELP_MESSAGE = <<~'TXT'.gsub(/^ {2}/, '')
  NAME
    copy_git_history_as_empty_commits 
      
      This tool allows you to "copy" blank git commits to a collapsed project 
      in order to save the history of commits messages.   
           
      WARNING:  
        This tool transfers only commit's metadata by `git commit --allow-empty` command 
        (see https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---allow-empty for reference)
  
        In case you want to preserve whole history, see these tools:
   
          * (git-filter-branch and git-rebase)[https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History]
          * (git-filter-repo)[https://github.com/newren/git-filter-repo/]
          * (bfg-repo-cleaner)[https://rtyley.github.io/bfg-repo-cleaner/]

  SYNOPSIS       
            
    ruby run.rb [OPTIONS]
             
  OPTIONS                         
    --help, -h
        Show this help. 
        

    -c <command> 
        One of main commands for the script running.
               

        POSSIBLE COMMANDS: 
          * build_index -- export commits from old project to the index directory
          * apply_index -- import commits to the new project from index directory  
         

        The `build_index` command:
        --------------------------

            This command will parse all git-commits from `--src_prj_dir` 
            and then will put the commits-info-files into `--index_dir`   
            
            RELATED OPTIONS:
              * --src_prj_dir          (required)  
              * --index_dir            (required)    
              * --msg_prefix           (optional)
              * --msg_postfix          (optional)     
              * --skip_merge_commits   (optional)   
  
  
            USAGE EXAMPLE:
              Build commits-info-files index: 
                
                  read -r -d '' msg_postfix << MSG
                      
                  ---------------
                  This commit was generated automatically,  
                  by https://github.com/alluviallabs/copy_git_history_as_empty_commits
                  
                  We took our private corporate project, deleted the git history,
                  removed our corporate stuff and imported most of the commits 
                  simply as a description and statistics, in order to understand 
                  who had what areas of responsibility for the project. 
                  MSG  
  
                  ruby run.rb \ 
                    --command build_index \
                    --src_prj_dir '/home/alex/prj/private_project' \
                    --index_dir '/tmp/commits_index_dir' \
                    --msg_prefix '[BLANK_COMMIT] ' \
                    --msg_postfix "$msg_postfix"
  
              This command will take each git-commit from `--src_prj_dir` (/home/alex/prj/private_project) 
              AND inside folder `--index_dir` (`/tmp/commits_index_dir`) will generate something like this:
                
                  /tmp/commits_index_dir/
                      ./c0001911_<sha_1911>_john_smith/  # most recent (last) commit
                      ...
                      ./c0000002_<sha_2>_vasya_pupkin/
                      ./c0000001_<sha_1>_john_smith/     # most ancient (first) commit
                          ./message.txt                 # commit message (you can change it)
                          ./info.json                   # parsed commit metadata   
          
               
              Now you can modify any `message.txt` or `info.json` if you want.

              You even can delete any commit containing folders (like `0000002_<sha_2>_vasya_pupkin/`),
              so this commits will not be imported.   
         
         The `apply_index` command:
         --------------------------

             This command will read continuously all commits-info-files in the directory, 
             specified with option `--index_dir`.
             
             Based on each commit-info-file, this command will create new blank commits 
             in the project with blank (new) git-repository, specified with option `--dst_prj_dir`.  
                  
             RELATED OPTIONS:
               * --index_dir       (required)
               * --dst_prj_dir     (required)  
             
             USAGE EXAMPLE:
                 Apply commits-info-files index to the new project:
    
                   ruby run.rb \ 
                     --command apply_index \
                     --index_dir './tmp/commits_index_dir' \
                     --new_prj_dir '/home/alex/prj/public_project_copy'     
                                                

     --src_prj_dir '/some/path/to/your/OLD/REAL/project'
        Your current private project, with real `.git`-database. 
        This project is the SOURCE, where from all commits will be taken.
        This option is safe to use, because it is read-only.
        This option is used on `build_index` stage.     
                 

    --dst_prj_dir '/some/path/to/your/new/project/with/collapsed/history'
        This is your copy-project (with new blank `.git`-database),
        where you want to import the commits-info-files (specified by `--index_dir` option)
        This option is used on `apply_index` stage.
        
        WARNING: 
          This option is dangerous, because it will modify .git-database in the specified path.   

  
    --index_dir '/some/path/to/temporary/index/directory'
        Empty folder, where commits-info-files will be exported.
        This folder used for temporary storage to allow you to edit (or delete) any commit messages.
        This option is used on both `build_index` and `apply_index` stages.

        If folder is not empty or is not exists, the exception will be raised.                 
              

    --msg_prefix '<prefix_string>'  
        Optional parameter. 
        If specified -- each commit-message will be prefixed by the <prefix_string>
        This option is used on `build_index` stage.               
             

    --msg_postfix '<postfix_string>'
        Optional parameter. 
        If specified -- the <postfix_string> will be added to the end of each commit-message.
        This option is used on `build_index` stage.
       

    --skip_merge_commits 
        Optional parameter. 
        If specified, all merge commits will be filtered  
        This option is used on `build_index` stage.     

    --include_original_sha
        Optional parameter
        Do include original commit-hash into the new commit-message? 
        If specified, at the bottom of the new commit-message, there will be line like this: 

            [ORIGINAL_COMMIT_HASH: <commit.sha>]\n
        
        This option is used on `build_index` stage.  

EXIT STATUS
     The copy_git_history_as_empty_commits utility exits with one of the following values:

     0       Everything is ok. 

     any other value
             An error occurred.
       
AUTHORS
     Alex Kalinin (login.hedin@gmail.com) while at the alluviallabs.com  

TXT
