## Table of Contents
* [Workflow](#workflow)
* [Scope](#scope)
* [Prerequisites](#prerequisites)
* [Tasks](#tasks)
  * [setup](#setup)
  * [rebase](#rebase)
  * [purge](#purge)
  * [aggregate](#aggregate)

## Workflow
This script will facilitate adopting a subset of the branch-featuring workflow characterised by:
* each **feature** will have **its own branch**
* **feature** branches **derive** directly **form master**
* **integration** of master to feature branch happens **via rebasing**
* rebasing interactively is used on feature branch to **squash commits** to get a **single one per feature** branch
* **pushing with force** on local branches is not an issue
* **release** branches are created **aggregating multiple branches** into a new one

## Scope
The scope of this is helping out in the following cases:
* you have multiple feature branches waiting for release due to some reason (i.e. long QA time...), and need to keep them aligned with master
* you need to quickly aggregate branches for a release

## Prerequisites
I assume you have GIT installed ;)

## Tasks
Here are the main tasks:

### setup
The core of the library is automating multiple branches fetching, this action happens in two concurrent ways:  
* from the command line, by splitting a comma separated list
* by reading a file where names are listed on each line
In case **no branches** are fetched the **script halts**.

Is also assumed you're pointing to a project directory somewhere, so the script could move in and execute the GIT commands for you.

To call this task with arguments call it like that:
```ruby
rake git_utils:setup repo=git_repository base_dir=repo_path branches_file=file_listing_branches branches=list,of,branches,separated,by,comma
```
Here are the arguments list:
* **repo**: the repository name you want to automate git commant to
* **base_dir**: the base path to your GIT repo, excluding its name (specified eralier). It defaults to HOME/Sites
* **branches_file**: the path to the file, if any, listing the branches names. It defaults to the **.branches** file inside of your repo path (you need to add it to the .gitignore then)
* **branches**: a list of branches separated by comma (optional), if specified it has precedence over the branches_file

### rebase
This is probably the most useful command in case you have several branch to rebase with _origin/master_ frequently.
Consider after the rebase the branch is pushed to origin with force, so be aware in case more than one programmer access the same branch from different computers.  
A confirmation is asked to continue.  

As the other tasks, it depends on the setup one, so it accepts the same arguments:
```ruby
# loads branches from the repo .branches file, repo si located at HOME/Sites/my_repo
rake git_utils:rebase repo=my_repo
```

### purge
This command remove the specified branches locally and remotely.  
A confirmation is asked before each removal.  
It uses the same arguments as setup:
```ruby
# purge old branches specified at the command line, repo is located at HOME/Sites/my_repo
rake git_utils:purge repo=my_repo branches=old_branch,older_branch,oldest_branch
```

### aggregate
It should be useful to aggregate your branches into a single one in case you want to create a release branch.  
It uses the following naming convention: rb_yyyy_mm_dd  
A confirmation is asked to continue.  
It uses the same arguments as setup:
```ruby
# aggregate branches listed in the /tmp/to_release file, repo si located at HOME/Sites/my_repo
rake git_utils:aggregate repo=my_repo branches_file=/tmp/to_release
```
