---
author: "Rodrigo Dumont"
date: 2013-10-21
linktitle: Give your git graph some bubbles
title: Give your git graph some bubbles
tags: [ git ]
highlight: true
---

The concept of a Version Control System is ususally misunderstood by most people. It isn't just about keeping track o what you do. Most of all, it is **about telling the story** of a system's development. It should be easily readable and undestandable by the whole team. It should have well defined chapters and lead the reader through what happened.

<!-- more -->


### Which would you rather deal with?

An intertwined graph with crossing edges and hard to follow lines:

![Messy Git graph](/assets/git-ugly-graph.png)

Or an organized graph with well-defined feature branches:

![Pretty Git graph](/assets/git-pretty-graph.png)

The examples above are both from real repositories. Both teams are roughly the same size and the systems aren't so different in terms of complexity either.


### Getting there

First, **every feature-ish increment has its own branch**. I usually define those branches as either:

 * **feature**: a new feature, whether it is high or low-level
 * **bug**: a bug fix
 * **refactor**: for refactoring, paying technical debt etc.
 * **hotfix**: rarely used, for quickly fixing problems that are in production

Second, **always rebase the feature branch on top of the base branch before merging**. The base branch can be whatever you like, but it is usually `master`, `dev`, `develop` or something like that. By rebasing the feature branch, you guarantee that the merge could be fast-forward. Therefore, you won't have to worry about how potential conflicts have been solved. This is very important when there are other people commiting to your base branch.

Last, **only merge to the base branch using the `--no-ff` flag**. This will make a merge commit even though it wouldn't be necessary. By doing this, you will always have a clear separation between features. Some of the advantages are that this way it is simpler to revert features and much easier to skim the git log looking for a feature.


### The flow

With these key points in mind, we can establish a flow that looks like the following.

```sh
$ git checkout -b featue/hello-world    # create the feature branch
$ # do the work on `hello-world
$ git checkout master
$ git pull origin master                # because someone else might have pushed to it
$ git checkout feature/hello-world
$ git rebase master                     # make sure that your branch is fast-forwardable to master 
$ git checkout master
$ git merge --no-ff feature/hello-world # merge with the bubble commit
$ git push origin master
```

Of course, this is a very basic flow. In a real scenario you might want to update a changelog or readme, increment version etc. But the important thing is that now your git history will be prettier and won't give you headaches for having to manage it.