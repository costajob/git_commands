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
This script facilitates adopting a subset of the branch-featuring workflow characterised by:
* each feature will have its own branch
* feature branches derive directly form master
* integration of master to feature branch happens via rebasing to maintain a straight commits line
* force pushing of feature branches to origin is not an issue
* release branches are created aggregating multiple branches

## Scope
The scope of this gem is helping out in the following cases:
* you have multiple feature branches waiting for release due to some reason (i.e. long QA time...), and need to keep them aligned with master
* you need to quickly aggregate branches for a release
* you want to cleanup local and remote branches upon release

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
Usage: rebase --repo=/Users/Elvis/greatest_hits --branches=feature/love_me_tender,fetaure/teddybear
    -r, --repo=REPO                  The path to the existing GIT repository
    -b, --branches=BRANCHES          Specify branches as: 1. a comma-separated list of names 2. the path to a file containing names on each line 3. via pattern matching
    -h, --help                       Prints this help
```

#### Repository
You have to specify the absolute path to the GIT repository you want to work with. The path must be a folder initialized as a valid GIT repository (a check via *rev-parse* is performed), otherwise an error is raised:

```
rebase --repo=invalid
'invalid' is not a valid GIT repository!
```

#### Branches
As with the repository you always have to specify the list of branches you want to work with. There are different options:

##### List of branches
Specify a comma separated list of branch names:

```
rebase --repo=/Users/Elvis/greatest_hits --branches=feature/love_me_tender,feature/teddybear,feature/return_to_sender

Loading branches file...
Successfully loaded 3 branches:
01. feature/love_me_tender
02. feature/teddybear
03. feature/return_to_sender
```

##### Path to a names file
Specify an absolute path to a file containing the branches names on each line:

File */Users/Elvis/greatest_hits/.branches*:
```
feature/love_me_tender
feature/teddybear
feature/return_to_sender
feature/in_the_ghetto
```

```
rebase --repo=/Users/Elvis/greatest_hits --branches=/Users/Elvis/greatest_hits/.branches

Loading branches file...
Successfully loaded 4 branches:
01. feature/love_me_tender
02. feature/teddybear
03. feature/return_to_sender
04. feature/in_the_ghetto
```

##### Pattern matching
In case you want to work with a set of branches with a common pattern, you have to specify a greedy operator with the wild card you want to match.  
Just consider you have not to specify *origin/* as the name of the branch, since is managed by the script for you: 

```
rebase --repo=/Users/Elvis/greatest_hits --branches=*der

Loading branches file...
Successfully loaded 2 branches:
01. feature/love_me_tender
02. feature/return_to_sender
```

##### Checking
Each loaded branch is validated for existence (but for branches loaded via pattern matching, already fetched from origin).   
In case the validation fails, the branch is filtered from the resulting list.

```
rebase --repo=/Users/Elvis/greatest_hits --branches=noent,feature/love_me_tender

Loading branches file...
Successfully loaded 1 branch:
01. feature/love_me_tender
```

In case no branches have been loaded, an error is raised:

```
rebase --repo=/Users/Elvis/greatest_hits --branches=noent1,noent2
No branches loaded!
```

##### Master branch
Master branch cannot be included into the branches list for obvious reasons:

```
rebase --repo=/Users/Elvis/greatest_hits --branches=master,feature/love_me_tender

Loading branches file...
Successfully loaded 1 branch:
01. feature/love_me_tender
```

### Commands
Here are the available GIT commands:

#### Rebase
This command is useful in case you have several branches to rebase with _origin/master_ frequently.
A confirmation is asked to before rebasing.  

```
rebase --repo=/Users/Elvis/greatest_hits --branches=feature/love_me_tender,feature/teddybear,feature/return_to_sender
...
```

#### Purge
This command remove the specified branches locally and remotely.  
A confirmation is asked before removal.  

```
purge --repo=/temp/top_20 --branches=*obsolete*
...
```

#### Aggregate
This command aggregates all of the specified branches into a single one in case you want to create a release branch.  
The created release branch follows this naming convention: *release/yyyy_mm_dd*  
A confirmation is asked before aggregating.  

```
aggregate --repo=/Users/Elvis/greatest_hits --branches=*ready*
```
