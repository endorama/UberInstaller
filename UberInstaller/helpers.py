#!/usr/bin/env python

import logging, sys

LOG_ONLY = False

def highlite(string, color, special = "none"):
  """Colourize output"""
  
  attr = []
    
  if color == "black":
    attr.append('30')
  elif color == "red":
    attr.append('31')
  elif color == "green":
    attr.append('32')
  elif color == "yellow":
    attr.append('33')
  elif color == "blue":
    attr.append('34')
  elif color == "magenta":
    attr.append('35')
  elif color == "cyan":
    attr.append('36')
  elif color == "white":
    attr.append('37')
  
  if special == "bold":
    attr.append('1')
  elif special == "underline":
    attr.append("2")
  
  return '\x1b[%sm%s\x1b[0m' % (';'.join(attr), string)


def debug(string = ""):
  return highlite("    [ DEBUG ] " + string, "blue", "bold")
  

def info(string = ""):
  return "     [ INFO ] " + string


def success(string = ""):
  return highlite("       [ OK ] " + string, "green", "bold")
 
  
def warning(string = ""):
  return highlite("  [ WARNING ] " + string, "yellow")
  

def error(string = ""):
  return highlite("    [ ERROR ] " + string, "red", "bold")
  

def critical(string = ""):
  return highlite(" [ CRITICAL ] " + string, "magenta", "bold")


def exception(string = ""):
  return highlite("[ EXCEPTION ] " + string, "magenta", "bold")


def suppress_traceback_message():
  """Define a new hook for handling Exception visualization.
     Prints only Exception type and Exception Instance message, without Traceback"""
  old_excepthook = sys.excepthook

  def new_hook(type, value, traceback):
    print exception(str(type.__name__) + ": " + str(value))
    old_excepthook('', '', traceback)
   
  sys.excepthook = new_hook


def out(level, message = '', no_newline = False):
  if not LOG_ONLY:
    if no_newline:
      sys.stdout.write( '%s' % globals()[level](message) )
    else:
      sys.stdout.write( '%s\n' % globals()[level](message) )

    sys.stdout.flush()

  # python logging has no "success" method. Using "info" instead
  if level == 'success':
    level = 'info'
    if message == '':
      message = 'OK'

  if no_newline:
    getattr(logging, level)(message)
  else:
    getattr(logging, level)(message)
