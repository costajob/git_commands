## Table of Contents
* [Workflow](#workflow)
* [Scope](#scope)
* [Installation](#installation)
  * [GIT](#git)
* [Usage](#usage)
  * [Arguments](#help)
    * [Help](#help)
    * [Repository](#repository)
    * [Branches](#branches)
  * [Commands](#commands)
    * [Rebase](#rebase)
    * [Purge](#purge)
    * [Aggregate](#aggregate)

## Workflow
This script will facilitate adopting a subset of the branch-featuring workflow characterised by:
* each **feature** will have **its own branch**
* **feature** branches **derive** directly **form master**
* **integration** of master to feature branch happens **via rebasing**
* **release** branches are created **aggregating multiple branches** into a new one

## Scope
The scope of this gem is helping out in the following cases:
* you have multiple feature branches waiting for release due to some reason (i.e. long QA time...), and need to keep them aligned with master
* you need to quickly aggregate branches for a release

## Installation
Just install the gem to use the binaries commands.
```
gem install git_commands
```

### GIT
The library uses the Ruby command line execution to invoke the **git** command as a separate process.  
I assume you have the GIT program on your path.

## Usage
Here are the main commands:

### Arguments
All of the available commands come with the same set of arguments:

#### Help
Display the help of a specific command by:

```
rebase --help
Usage: rebase --repo=./Sites/oro --branches=feature/add_bin,fetaure/remove_rake_task
    -r, --repo=REPO                  The path to the existing GIT repository
    -b, --branches=BRANCHES          The comma-separated list of branches or the path to a file listing branches names on each line
    -h, --help                       Prints this help
```

#### Repository
You have to specify the path (absolute or relative) to the GIT repository you want to work with. The path must be a folder initialized as a valid GIT repository (a check via *rev-parse* is performed), otherwise an error is raised:

```
rebase --repo=invalid
'invalid' is not a valid GIT repository!
```

#### Branches
Along with the repository you always have to specify the list of branches you want the command to interact with.  
You have two main options here:

##### List of branches
Specify a comma separated list of branch names:

```
rebase --branches=feature/love_me_tender,feature/teddybear,feature/return_to_sender

Loading branches file...
Successfully loaded 3 branches:
01. feature/love_me_tender
02. feature/teddybear
03. feature/return_to_sender
```

##### Path to a names file
Specify a path (absolute or relative) to a file containing the branches names on each line:

File *./Sites/greatest_hits*:
```
feature/love_me_tender
feature/teddybear
feature/return_to_sender
feature/in_the_ghetto
```

```
rebase --branches=./Sites/greatest_hits

Loading branches file...
Successfully loaded 4 branches:
01. feature/love_me_tender
02. feature/teddybear
03. feature/return_to_sender
04. feature/in_the_ghetto
```

##### Checking
Each loaded branch is validated for existence (via *rev-parse*), in case it does not an error is raised:

```
rebase --repo=./Sites/greatest_hits --branches=noent

Loading branches file...
Branch 'noent' does not exist!
```

##### Master branch
Master branch cannot be included into the branches list for obvious reasons (from useless to dangerous ones).
An error is raised in case master branch is specified:

```
rebase --repo=./Sites/greatest_hits --branches=master

Loading branches file...
Commands cannot interact directly with 'master' branch!
```

### Commands
Here are the available GIT commands:

#### Rebase
This is probably the most useful command in case you have several branches to rebase with _origin/master_ frequently.
A confirmation is asked to before rebasing.  

```
rebase --repo=./Sites/greatest_hits --branches=feature/love_me_tender,feature/teddybear,feature/return_to_sender
...
```

#### Purge
This command remove the specified branches locally and remotely.  
A confirmation is asked before removal.  

```
purge --repo=/temp/top_20 --branches=release/in_the_ghetto
...
```

#### Aggregate
This command aggregates all of the specified branches into a single one in case you want to create a release branch.  
It uses the following naming convention: *release/yyyy_mm_dd*  
A confirmation is asked before aggregating.  

```
aggregate --repo=./Sites/greatest_hits --branches=./Sites/greatest_hits
```
