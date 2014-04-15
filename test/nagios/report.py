system = 'undefined'

def report(code, message):
    codes = {0: 'OK', 1: 'WARNING', 2: 'CRITICAL', 3: 'UNKNOWN'}
    print "%d %s - %s - %s" % \
        (code, system, codes[code], message)
    exit(code)

def fail(message):
    report(2, message)

def warn(message):
    report(1, message)

def ok(message):
    report(0, message)

def unknown(message):
    report(3, message)
