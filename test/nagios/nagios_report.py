def functions_for_system(under_test):
    """
    returns a set of functions to use for nagios reporting:
    >>> ok, warn, critical, unknown = functions_for_system("tested system")
    
    each of them will print a nagios line with its argument and
    return the exit code:
    >>> warn("that looks strange")
    1 tested system - WARNING - that looks strange
    1
    """
    def report_function(code):
        return lambda message : report(under_test, code, message)
    return map(report_function, [0,1,2,3])

def report(system, code, message):
    codes = {0: 'OK', 1: 'WARNING', 2: 'CRITICAL', 3: 'UNKNOWN'}
    print "%d %s - %s - %s" % \
        (code, system, codes[code], message)
    return code

if __name__ == "__main__":
    import doctest
    doctest.testmod()
