## Table of Contents
* [Workflow](#workflow)
* [Scope](#scope)
* [Installation](#installation)
* [Usage](#usage)
  * [Help](#help)
  * [rebase](#rebase)
  * [purge](#purge)
  * [aggregate](#aggregate)

## Workflow
This script will facilitate adopting a subset of the branch-featuring workflow characterised by:
* each **feature** will have **its own branch**
* **feature** branches **derive** directly **form master**
* **integration** of master to feature branch happens **via rebasing**
* **release** branches are created **aggregating multiple branches** into a new one

## Scope
The scope of this is helping out in the following cases:
* you have multiple feature branches waiting for release due to some reason (i.e. long QA time...), and need to keep them aligned with master
* you need to quickly aggregate branches for a release

## Installation
I assume you have GIT installed ;)  
Just install the gem to use the binaries commands.
```
`gem isntall git_commands
```

## Usage
Here are the main commands:

### Help
Each command has an help option that can be displayed:

```
rebase --help
Usage: rebase --repo=./Sites/oro --branches=feature/add_bin,fetaure/remove_rake_task
    -r, --repo=REPO                  The path to the existing GIT repository
    -b, --branches=BRANCHES          The comma-separated list of branches or the path to a .branches files
    -h, --help                       Prints this help
```

### rebase
This is probably the most useful command in case you have several branches to rebase with _origin/master_ frequently.
A confirmation is asked to continue.  

```
rebase --repo=~/Sites/greatest_hits --branches=feature/love_me_tender,feature/teddybear,feature/return_to_sender
```

You can also specify as the *branches* the path to a file containing multiple branches on each line:

```
rebase --repo=~/Sites/greatest_hits --branches=~/greatest_hits/.branches
```

### purge
This command remove the specified branches locally and remotely.  
A confirmation is asked before each removal.  

```
purge --repo=~/temp/top_20 --branches=release/in_the_ghetto
```

### aggregate
It should be useful to aggregate your branches into a single one in case you want to create a release branch.  
It uses the following naming convention: *release/yyyy_mm_dd*  
A confirmation is asked to continue.  

```
aggregate --repo=~/Sites/greatest_hits --branches=~/greatest_hits/.branches
```
