import __main__ as main
import os
import sys
import nagios_report

def run(test):
    """
    run takes a function and tries it out.
    If it returns nothing or 0 everything is fine and run prints an OK message
    with the function name.
    >>> def this_works_fine(): return
    >>> run(this_works_fine)
    0 nagios_test.py - OK - this_works_fine
    0
    >>> def this_also_works_fine(): return 0
    >>> run(this_also_works_fine)
    0 nagios_test.py - OK - this_also_works_fine
    0

    If the function returns something else it will be printed as a warning.
    >>> run(lambda : "this is a warning")
    1 nagios_test.py - WARNING - this is a warning
    1

    Errors raised will result in a CRITICAL nagios string.
    >>> def failure(): raise Exception("something went wrong")
    >>> run(failure)
    2 nagios_test.py - CRITICAL - something went wrong
    2
    """
    try:
        name = os.path.basename(main.__file__)
    except AttributeError: 
        name = sys.argv[0]
    ok, warn, fail, unknown = nagios_report.functions_for_system(name)
    try:
        warning = test()
        if warning and warning != 0:
            code = warn(warning)
        else:
            code = ok(test.__name__)
    except Exception as exc:
        code = fail(exc.message or str(exc))
    return code


if __name__ == "__main__":
    import doctest
    doctest.testmod()
