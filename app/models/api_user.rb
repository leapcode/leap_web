
class ApiUser < AnonymousUser
end

#
# A user that has limited admin access, to be used
# for running monitor tests against a live production
# installation.
#
class ApiMonitorUser < ApiUser
  def is_monitor?
    true
  end
end

#
# Not yet supported:
#
#class ApiAdminUser < ApiUser
#  def is_admin?
#    true
#  end
#end