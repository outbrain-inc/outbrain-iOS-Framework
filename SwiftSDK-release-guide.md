# SwiftSDK Release Guide

## Step 1

start from branch `main_SwiftSDK`

checkout to a new branch which starts with 5.x.x 

Important: DO NOT add "beta or alpha" to the branch name, this will happen automatically in our CI. 

A working example would be: 
```
git checkout -b release/5.0.3
```

## Step 2

In branch `release/5.x.x`

Edit `release-notes.md` with the new release (branch name + beta) + date + content of the release.

## Step 3

Run 

```
git add release-notes.md
git push
```

## Step 4

Monitor the CI in https://app.circleci.com/pipelines/github/outbrain/iOS-sdk 

Check that `ios_default` passes

Check that `ios_release` passes

## Step 5

In your local Mac, go to your local copy of this repo https://github.com/outbrain/outbrain-iOS-Framework 
(if you don't have it, `git clone` it into your machine).

1) In `main` branch, run `git pull`  - you should find a new branch called by the same name as your new version with a prefix "ci-", for example `ci-5.x.x-beta`. run `git branch -a | grep ci` to view all branches with `ci` in them.
2) We want to be in the context of this branch, so we need to run `git checkout ci-5.x.x-beta`
3) run `git pull` again to verify latest commit.
4) Please note, the content of this new version is inside the file `OutbrainSDK.podspec` - this is the metadata for the new version. No action-step here, just for you to know.
5) Make sure you are connected 
6) Verify you are connected with Cocoapods by running `pod trunk me` - if you're not connected run `pod trunk register <my email>`
7) Run Lint and Push
```
pod spec lint
pod trunk push OutbrainSDK.podspec
```


