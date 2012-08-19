"""
A module rapresenting an installer

Error codes: 
  - 125 => package file system version different from host system version
  - 126 => package file arch is different from host system arch
  - 127 => user input aborting
"""

import json, logging, os, os.path, subprocess, sys, urllib2, time

import aptsources.distro

from JsonMinify import json_minify
from exceptions import handle_exception, handle_runned_command_exception
from exceptions import RunnedCommandException
import helpers as Helper
import user_input as UserInput

DRY_RUN = False
FORCE = False

def new(package_file_data):
  """
  Create and return an instance of the class
  """
  return Installer(package_file_data)

class Installer:

  # if system is 64 or 32 bit
  is_64_bit = False

  # error in execution will be stored here
  errors = []
  
  parse_warnings = []
  parse_errors = []

  # Make available to all methods configuration file
  _conf_file = None
  # path to configuration file
  _conf_file_path = None
  # path to packages folder ( calculated on conf file path )
  _pkgs_file_path = None

  # packages after parsing
  parsed_packages = {}

  def __init__(self, data_file_path):
    Helper.out('info', 'initializing installer')

    # retrive data from JSON file
    data = self._get_data_from_json(data_file_path)

    # make disposable to all methods packages data
    self._conf_file = data

    self._conf_file_path = data_file_path
    self._pkgs_file_path = os.path.join(os.path.dirname(data_file_path), 'pkgs')

    
  def check_requirements(self):
    package_meta = self._conf_file['meta']

    if not FORCE:
      # get current sistem codename
      os_codename = aptsources.distro.get_distro().codename
      
      # Check that codename in the file is equale to the current installed operative system
      if not package_meta['version'] == os_codename:
        Helper.out('error', "The packages file version do not meet the host version: package was build for " + package_meta['version'] + " but " + os_codename + " was found")
        exit(125)
      else:
        Helper.out('success', 'Correct OS version')
      
      # get current architecture
      self.is_64_bit = sys.maxsize > 2**32

      # Check that architecture is as specified in the file
      if ( package_meta['arch'] == '32' and self.is_64_bit ) or ( package_meta['arch'] == '64' and not self.is_64_bit ):
        print "The packages file architecture do not meet the host architecture: package was build for " + package_meta['arch'] + " but os",
        if self.is_64_bit:
          print "is 64 bit"
        else:
          print "is 32 bit"
        exit(126)
      else:
        Helper.out('success', 'Correct OS architecture')
    else:
      Helper.out('warning', 'Force option specified, check on host OS version and architecture disabled')


  def parse(self, packages = None):
    """ Parse the packages array and correctly initialize datas """
    
    print ""
    Helper.out('info', 'Parsing packages...')

    if not packages:
      packages= self._conf_file['packages']

    Helper.out('info', "Fetching", True)

    for p in sorted(packages.iterkeys()):

      sys.stdout.write( ' %s,' % p )
      sys.stdout.flush()
      logging.info(p)

      name = p          # name of the package
      p = packages[p]   # package data
      is_ok = False     # package data verification

      if not 'type' in p:
        p['type'] = 'default'
      if not 'skip' in p:
        p['skip'] = False

      # check if type is specified
      if 'type' in p:
        if p['type'] == 'default':
          is_ok = self._check_type_default(name, p)
        elif p['type'] == 'offline':
          is_ok = self._check_type_offline(name, p)
        elif p['type'] == 'git':
          is_ok = self._check_type_git(name, p)
        else:
          self.parse_errors.append(name + ': "type" parameter value is not supported. Must be one of "default", "offline", "git" or leaved blank ( reverts to "default" )')

      if is_ok:
        pack = { name : p }
        self.parsed_packages.update(pack)

      time.sleep(0.15)

    print ""

    # if there were warning, print them
    if self.parse_warnings:
      for w in self.parse_warnings:
        Helper.out('warning', w)

      UserInput.warning_proceeding("Continue")

    # if there were errors, print them ( and ask for aborting )
    if self.parse_errors:
      for e in self.parse_errors:
        Helper.out('error', e)

      Helper.out('warning', 'Continuing may lead to system damages or not working software.\n \
             All packages with errors will be excluded from installation, to prevent system harming.') 
      UserInput.critical_proceeding("Would you like to continue anyway")


  def run(self, packages = None):
    """ Perform package installation """
    
    print ""
    Helper.out('info', 'Processing packages...')
    if DRY_RUN:
      Helper.out('warning', 'Dry run mode specified')

    if not packages:
      packages = self._conf_file['packages']

    for package_name in sorted(packages.iterkeys()):
      pkg = packages[package_name]
      
      Helper.out('info', 'Preprocessing "' + package_name + '"')
      out_prefix = '=> '

      if not pkg['skip']:
        # before install
        if pkg['type'] == 'default':
          if 'ppa' in pkg:
            Helper.out('info', out_prefix + 'Installing PPA                     ', True)

            if self._install_ppa_repo(pkg['ppa']):
              Helper.out('success', '')
            else:
              Helper.out('error', '')
              pkg['skip'] = True

          if 'repo' in pkg:
            Helper.out('info', out_prefix + 'Installing Repository              ', True)

            if self._install_ppa_repo(pkg['repo']):
              Helper.out('success', '')
            else:
              Helper.out('error', '')
              pkg['skip'] = True

        elif pkg['type'] == 'offline':
          pass
        elif pkg['type'] == 'git':
          pass
      else:
        Helper.out('warning', out_prefix + 'Package skip option has been specified')

    print ""

    for package_name in sorted(packages.iterkeys()):
      pkg = packages[package_name]

      Helper.out('info', 'Processing "' + package_name + '"')
      out_prefix = '=> '

      if not pkg['skip']:
        # execute before commands
        if 'cmd' in pkg:
          if 'before' in pkg['cmd']:
            for cmd in pkg['cmd']['before']:
              try:
                Helper.out('info', out_prefix + 'Running before command             ', True)
                self._run_command(cmd)
              except RunnedCommandException as e:
                Helper.out('error')
                handle_runned_command_exception(e)
              else:
                Helper.out('success', '')

        # install
        if 'pkg' in pkg:
          for p in pkg['pkg']:
            try:
              if pkg['type'] == 'default':
                Helper.out('info', out_prefix + 'Installing via apt-get             ', True)
                self._install_type_default(p)
              elif pkg['type'] == 'offline':
                Helper.out('info', out_prefix + 'Installing via offline package     ', True)
                self._install_type_offline(p)
              elif pkg['type'] == 'git':
                Helper.out('info', out_prefix + 'Installing via git                 ', True)
                self._install_type_git(p)
            except RunnedCommandException as e:
              Helper.out('error')
              Helper.out('error', 'Error processing %s' % p)
              handle_runned_command_exception(e)
            except Exception as e:
              Helper.out('error')
              Helper.out('error', 'Error processing %s' % p)
              handle_exception(e)
            else:
              Helper.out('success')

        # execute after commands
        if 'cmd' in pkg:
          if 'after' in pkg['cmd']:
            for cmd in pkg['cmd']['after']:
              try:
                Helper.out('info', out_prefix + 'Running after command              ', True)
                self._run_command(cmd)
              except RunnedCommandException as e:
                Helper.out('error')
                handle_runned_command_exception(e)
              else:
                Helper.out('success', '')
      else:
        Helper.out('warning', out_prefix + 'Package skip option has been specified')




  def _check_type_default(self, name, package):
    """ Check that package is ready for default installation type """
    is_ok = True
    
    # check if 'pkg' is specified
    if not 'pkg' in package or len(package['pkg']) == 0:
      self.parse_warnings.append(name + ": no package selected")
      is_ok = False

    # if ppa is specified check for launchpad
    if 'ppa' in package:
      # get json from launchpad
      from softwareproperties.ppa import get_ppa_info_from_lp
      user, sep, ppa_name = package['ppa'].split(":")[1].partition("/")
      
      ppa_name = ppa_name or "ppa"
      
      try:
        get_ppa_info_from_lp(user, ppa_name)
      except:
        self.parse_errors.append(name + ': PPA does not exists')
        is_ok = False
    
    # if repo is specified check that it is reacheable
    if 'repo' in package:
      # build correct repository url
      repo = package['repo'].split(' ')
      url = repo[0] + '/dists/' + repo[1] + '/' + repo[2]

      try:
        urllib2.urlopen(url)
      except:
        self.parse_errors.append(name + ': package repository does not exists')
        is_ok = False

    return is_ok


  def _check_type_git(self, name, package):
    """ Check that package is ready for git installation """
    is_ok = True

    if not 'folder' in package['cvs']:
      package['cvs']['folder'] = os.path.join("/opt", os.path.splitext(package['cvs']['url'].split('/')[-1])[0])

    # build git url
    url = package['cvs']['url']
    if url[0:3] == 'git' or url[0:3] == 'ssh':
      url = 'http' + url[3:]

    try:
      urllib2.urlopen(url)
    except:
      self.parse_errors.append(name + ': git repository does not exists')
      is_ok = False

    package['pkg'] = [ '%s "%s"' % (package['cvs']['url'], package['cvs']['folder']) ]

    return is_ok


  def _check_type_offline(self, name, package):
    """ Check that package is ready for offline installation """
    is_ok = True

    # check if 'pkg' is specified
    if 'pkg' in package and len(package['pkg']) != 0:
      file_path = os.path.join(self._pkgs_file_path, package['pkg'])
      
      # check if file exists
      if os.path.isfile(file_path):
        file_name, file_ext = os.path.splitext(file_path)

        # check if extension is allowed
        if file_ext in ('.bin', '.deb', '.run'):
          # check if file is executable
          if os.access(file_path, os.X_OK):
            package['pkg'] = [ file_path ]
          else:
            self.parse_errors.append(name + ': file has no execution permissions, and cannot be installed')
            is_ok = False
        else:
          self.parse_errors.append(name + ': file extension available are .bin, .deb, .run')
          is_ok = False
      else:
        self.parse_errors.append(name + ': file does not exists')
        is_ok = False
    else:
      self.parse_warnings.append(name + ": no package selected")
      is_ok = False

    return is_ok
      

  def _get_data_from_json(self, data_file_path):
    """ Load packages data from the specified JSON file """
    input_text = json_minify(open(data_file_path).read())

    data = None
    try:
      data = json.loads(input_text)
    except ValueError, e:
      print "Invalid JSON. %s." % e
      print "You could use a tool such http://jsonlint.com/ ( credits to Arc90 Lab ) to lint and verify JSON file."

    return data


  def _install_ppa_repo(self, ppa):
    """ Add a PPA or a repository to the system """
    if DRY_RUN:
      return True

    return self._run_command('sudo apt-add-repository -y "%s"' % ppa)

  def _install_type_default(self, pkg):
    """" Perform default installation """
    if DRY_RUN:
      return True
    
    return self._run_command('sudo apt-get install -y -qq "%s"' % (pkg))


  def _install_type_git(self, pkg):
    """ Perform git installation """
    if DRY_RUN:
      return True

    return self._run_command('git clone %s' % pkg)
    

  def _install_type_offline(self, pkg):
    """" Perform offline installation """
    if DRY_RUN:
      return True

    pkg_name, pkg_ext = os.path.splitext(pkg)

    if pkg_ext in ('.deb'):
      cmd = 'sudo dpkg -i "%s"' % pkg
    elif pkg_ext in ('.bin', '.run'):
      cmd = 'sudo "%s"' % pkg
    
    return self._run_command(cmd)


  def _run_command(self, cmd):
    """ Execute arbitrary command """
    if DRY_RUN:
      return True

    logging.info(cmd)
    
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    for line in iter(process.stdout.readline, ""):
      logging.debug(line)

    stdout, stderr = process.communicate()

    # if stdout:
    #     logging.debug(stdout)
    # if stderr:
    #   logging.warning(stderr)

    if process.returncode == 0:
      return True
    else:
      raise RunnedCommandException(cmd, process.returncode, stdout, stderr)



  
