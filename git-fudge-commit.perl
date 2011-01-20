#!/usr/bin/perl -w

use strict;
use Git;

binmode(STDOUT, ":raw");

sub error {
    my $message = shift;
    print STDERR 'Unable to generate a sane commit: '.$message.v10;
    exit 1
}

sub normalize_tree_line {
    my $repo = shift;
    my $original_line = shift;
    my @revs = split /\s+/, $original_line;
    shift @revs;

    my @cmd = ['rev-parse'];
    push @cmd, @revs;
    print $repo->command(@cmd, STDERR => 0) or
        error 'cannot parse tree parameter';

printf STDERR 'Okay! :D'.v10;
exit 0;
=doc
    git rev-parse "${line#tree }" >/dev/null 2>&1 ||
        error_insane "cannot parse tree parameter"

    rev=`git rev-parse "${line#tree }"`
    num_lines=`printf '%s\n' "$rev" | wc -l`
    if [ -n "$rev" -a $num_lines -eq 1 ]; then
        rev=`git rev-parse "$rev^{}"`
        type=`git cat-file -t "$rev"`
        if [ "$type" = "tree" ]; then
            tree="$rev"
        elif [ "$type" = "commit" ]; then
            tree=`git rev-parse "$rev:"`
        else
            error_insane "no parameter could be converted into tree object"
        fi
    elif [ $num_lines -gt 1 ]; then
        rev=`printf '%s' "$rev"|tr '\n' ' '`
        rev=`git rev-list -2 $rev`
        num_lines=`printf '%s\n' "$rev" | wc -l`
        if [ $num_lines -gt 1 ]; then
            error_insane "specified parameter resolves into multiple trees"
        elif [ -z "$rev" -o $num_lines -lt 1 ]; then
            error_insane "specified tree parameter does not resolve into an object"
        fi
        rev=`printf '%s' "$rev"|tr '\n' ' '`
        tree=`git rev-parse "$rev:"`
    else
        error_insane "specified tree parameter does not resolve into an object"
    fi
    echo "$tree"
=cut
}

my $repos = Git->repository (Directory => '.git');
normalize_tree_line( $repos, 'tree HEAD' );
