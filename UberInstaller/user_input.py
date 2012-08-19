import UberInstaller.helpers as Helper

ASSUME_YES = False
ASSUME_NO = False

def critical_proceeding(message):
  Helper.out('warning', message + '? [y/N] ', True)
  
  if not ASSUME_YES:
    go_on = raw_input()
  else:
    print ""

  if ASSUME_YES or go_on == 'y':
    # Helper.out('info', 'Proceeding...')
    pass
  else:
    Helper.out('critical', 'Aborting installation')
    exit(127)

def warning_proceeding(message):
  if ASSUME_NO:
    Helper.out('warning', message + '? [Y/n] ', True)
    go_on = raw_input()
  else:
    go_on = None
    print ""

  if ASSUME_NO or go_on == 'n':
    Helper.out('critical', 'Aborting installation')
    exit(127)
  else:
    # Helper.out('info', 'Proceeding...')
    pass
    
