#!/bin/bash -e

echo "hello"
function startbitbucket {
    echo 'Username?'
    read username
    echo 'Password?'
    read password
    echo 'Repo name?'
    read reponame

    git init
    git add -A .
    git commit -m "Initial commit"
    # curl --user $username:$password https://api.bitbucket.org/1.0/repositories/ --data name=$reponame --data is_private='true'
    curl -X POST -v -u ${username}:${password} -H "Content-Type: application/json" https://api.bitbucket.org/2.0/repositories/${username}/${reponame} -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'

    git remote add origin git@bitbucket.org:$username/$reponame.git
    git push -u origin --all
    git push -u origin --tags
}
startbitbucket