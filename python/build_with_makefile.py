#!/usr/bin/env python


'''
TODO list:
- Windows support
    - How to handle the host path for mounting?
'''


import os
import sys
import platform
import argparse
import subprocess


# Helper variables
basedir = os.getcwd()
here = os.path.abspath(os.path.dirname(__file__))


# Helper functions
def print_info(s):
    print '[%s]: %s' % (__file__, s)


def mkdir_if_needed(path):
    try:
        if not os.path.isdir(path):
            os.mkdir(path)
    except:
        assert False, 'Creating %s failed' % path


DRY = True
def do(cmd, dry=None):
    def _convert_to_str(cmd):
        if type(cmd) == type(list()):
            cmd = ' '.join(cmd)
        return cmd

    def _convert_str_to_lst(cmd):
        if type(cmd) == type(str()):
            lst = list()
            for x in cmd.split(' '):
                lst.append(x)
        else:
            lst = cmd

        return lst

    if dry is None:
        dry = DRY

    cmd = _convert_to_str(cmd)
    print 'CMD > ' + cmd
    if dry is False:
        cmd = _convert_str_to_lst(cmd)
        subprocess.check_call(cmd)


## Functions for building binaries

def build_in_docker_container(make_dir,
                              make_file='Makefile',
                              make_target='clean',
                              parallel=False,
                              docker_image='gcc:5.2'):
    try:
        import docker
    except ImportError:
        raise Exception('''
### Some packages are not ready. Please run: ###
python -m pip install --user docker
''')

    make_dir_abspath = os.path.abspath(make_dir)
    ## TODO: currently, following line is not working on Windows
    host_mnt_root = os.path.sep + make_dir_abspath.split(os.path.sep)[1] ## Example: /Users
    container_mnt_root = '/mnt' + host_mnt_root
    vol_dict = {host_mnt_root: {'bind': container_mnt_root, 'mode': 'rw'}}

    flag_j = '' if parallel is False else '-j'
    cmd = 'make {} -C /mnt{} -f {} {}'.format(flag_j, make_dir_abspath, make_file, make_target)

    client = docker.from_env()

    print 'BUILDING ...'
    logs = client.containers.run(docker_image, cmd, remove=True, volumes=vol_dict)
    print logs

    ## Detach mode is not working as expectation. Reason is unknown yet.
    # container = client.containers.run('gcc:5.2', cmd, volumes=vol_dict, detach=True)
    # container.logs()
    # container.stop()


def build(makedir, makefile, target, parallel, docker_image=None):
    if docker_image is not None:
        build_in_docker_container(makedir, makefile, target,
                                  parallel, docker_image)
    else:
        flag_j = '' if parallel is False else '-j'
        cmd = 'make {} -C {} -f {} {}'.format(flag_j, makedir, makefile, target)
        do(cmd, dry=False)

    return os.path.join(os.path.abspath(makedir), target)


# Main
def main():
    parser = argparse.ArgumentParser(
        description='Build the binaries for Linux platform. Makefile based.',
        epilog='Docker container environment is supported.')

    parser.add_argument(
        '-v',
        '--verbose',
        dest='verbose',
        action='store_true',
        default=False,
        help='Display more information.')
    parser.add_argument(
        '-j',
        dest='parallel',
        action='store_true',
        default=False,
        help='Enable -j option for make command.')
    parser.add_argument(
        '-d',
        '--docker',
        dest='docker_image',
        action='store',
        default=None,
        help='Specify a docker image to create a container for the binary building.'
    )
    parser.add_argument(
        '-c',
        '--change-dir',
        dest='makedir',
        action='store',
        default='.',
        help='Change the directory and build the binary.')
    parser.add_argument(
        '-f',
        '--makefile',
        dest='makefile',
        action='store',
        default='Makefile',
        help='Specify the name of makefile and build the binary.')
    parser.add_argument('target', help='Build target name in Makefile.')

    args = parser.parse_args()

    bin_path = build(args.makedir, args.makefile, args.target, args.parallel, args.docker_image)

    print bin_path


if __name__ == '__main__':
    sys.exit(main())