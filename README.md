git_utils
===========

Utility library to work with remote repositories listed inside plain files. 

# Workflow
This script will facilitate adopting a subset of the branch-featuring workflow characterised by:
* each feature will have its own branch
* feature branches derive directly form master
* integration of master to feature branch happens via rebasing
* rebasing interactively is used on feature branch to squash comments and get a single commit per feature branch
* release branches are created aggregating multiple branches into a new one

# Utility
This script will help you in the following cases:
* you have multiple feature branches waiting for release due to some reason (i.e. long QA time...), and need to keep them aligned with master
* you need to quickly aggregate branches for a release

# Prerequisites
You need **Ruby >= 1.8.7** and **rake >= 0.8.7**, further than **GIT >= 1.7**

# Tasks
Print out all of the available tasks by hiting:

    rake -T

Here are the main ones:
* **rake git:aggregate**       # Aggregate specified branches into a single one by using the following naming convention: rb_yyyy_mm_dd
* **rake git:basedirs**        # Set the base directory
* **rake git:rebase**          # Rebase the specified branches with master with options
* **rake git:remove**          # Remove the specified branch/branches locally and from origin (ask for confirmation)

## Setting your base paths
The entire library works by fetching branches names for plain text
file. 
It also assumes you're pointing to a project directory somewhere, so the script could move in and execute the GIT commands for you.
The script uses the following directories names:
* **projdir**: the path to your GIT repo
* **filedir**: the path to the file containing your branches names, one per line

Default values for these paths are: 

    $HOME/Sites

To set these path pass the following arguments to the rake task:

    rake git:rebase PROJ_DIR=/my/project FILE_DIR=/my/branches

You can use both relative and absolute (recommended) paths.

## Rebase your branches
This is probably the most useful command in case you have several branch to rebase with _origin/master_ frequently.

    rake git:rebase

To rebase interactively:

    rake git:rebase opts=i

## Aggregate your branches
It should be useful to aggregate your branches into a single one in case you want to create a release branch.

    rake git:aggregate

## Delete your branches
This command remove all of your branches locally and on origin. A confirmation is asked before the removal.

    rake git:remove
