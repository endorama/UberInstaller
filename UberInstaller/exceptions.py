
import helpers as Helper
import user_input as UserInput

def handle_exception(e):
  Helper.out('exception', '%s' % e)
  UserInput.critical_proceeding('Would you like to continue anyway')

def handle_runned_command_exception(e):
  Helper.out('error', '%s' % e.command)
  Helper.out('error', '%s' % e.stderr)
  UserInput.critical_proceeding('Would you like to continue anyway')

class RunnedCommandException(BaseException):
  """docstring for RunnedCommandException"""
  def __init__(self, cmd, retcode, stdout, stderr):
    self.command = cmd.strip()
    self.returncode = retcode
    self.stdout = stdout.strip()
    self.stderr = stderr.strip()

  def __str__(self):
    return "RunnedCommandException: install program exited with non zero status \n\
              command     : %s \n\
              return code : %s \n\
              standard out: %s \n\
              standard err: %s" % ( self.command, self.returncode, self.stdout, self.stderr )
    
