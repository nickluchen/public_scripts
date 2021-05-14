#!/usr/bin/env python

import os
import re
import argparse
import subprocess

## Helper variables
basedir = os.getcwd()
here    = os.path.abspath(os.path.dirname(__file__))


## Helper functions
def print_info(s):
    print '[%s]: %s' % (__file__, s)


# Main
def main():
    parser = argparse.ArgumentParser(description='An helper script to implement p4 blame.',
                                     epilog='''Prerequisites: 1) p4 / p4.exe is available on command line; 2) set the environment variable P4CLIENT either in P4CONFIG file or manually in console.
                                                E.g. On Linux / macOS:
                                                     export P4CLIENT=your_current_p4_workspace
                                                     On Windows:
                                                     set P4CLIENT=your_current_p4_workspace'''
                                    )

    parser.add_argument('src_file',
                        help='The source file to be analyzed.'
                       )

    args = parser.parse_args()

    ## Get the full file log by
    ##     p4 filelog foo.c
    p1_cmdline = ['p4', 'filelog', args.src_file]

    p1 = subprocess.Popen(p1_cmdline, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (p1_child_stdout, p1_child_stderr) = p1.communicate()

    if p1_child_stderr:
        print p1_child_stderr
        exit(-1)

    cl_info = dict()

    for p1_line in p1_child_stdout.split(os.linesep):
        ## The revision information pattern
        ## ... #1 change 358646 move/add on Bla-bla
        tmp_str = re.search('... #\d+', p1_line)
        if tmp_str is not None:
            ## Get the version number
            version = tmp_str.group(0).lstrip('... #')
            ## Get the change list number
            changelist = re.search(' change \d+', p1_line).group(0).lstrip(' change ')

            ## Get the user name from the change list information, without user interaction
            ##     p4 change -o #changelistnum
            p2_cmdline = ['p4', 'change', '-o', changelist]
            p2 = subprocess.Popen(p2_cmdline, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            (p2_child_stdout, p2_child_stderr) = p2.communicate()

            for p2_line in p2_child_stdout.split(os.linesep):
                ## The user name information pattern
                ## User:   bar
                tmp_str = re.search('^User:\s+\w+', p2_line)
                if tmp_str is not None:
                    user = tmp_str.group(0).lstrip('User:').lstrip()
                    ## Adding more trailing whitespaces
                    if len(user) < 8:
                        user += ' ' * (8 - len(user))

            ## Structure:
            ##     cl_info[1] = [bar, 123456]
            ##     cl_info[2] = [baz, 123654]
            changelist = changelist if len(changelist) >= 9 else (' ' * (9 - len(changelist)) + changelist)
            cl_info[version] = [user, changelist]

    ## Get the revision information of each line
    p1_cmdline = ['p4', 'annotate', args.src_file]

    p1 = subprocess.Popen(p1_cmdline, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (p1_child_stdout, p1_child_stderr) = p1.communicate()

    outbuf = str()

    for p1_line in p1_child_stdout.split(os.linesep):
        ## Replace the revision number with the associated user name
        ## E.g.:
        ##     1       : #include <stdio.h>
        ## to
        ##     bar     :     123456: #include <stdio.h>
        tmp_str = re.search('^\d+:', p1_line)
        if tmp_str is not None:
            new_info = cl_info[tmp_str.group(0).rstrip(':')][0] + ': ' + cl_info[tmp_str.group(0).rstrip(':')][1] + ' :'
            outbuf += p1_line.replace(tmp_str.group(0), new_info)
        else:
            outbuf += p1_line
        outbuf += os.linesep

    print outbuf

if __name__ == '__main__':
    main()

