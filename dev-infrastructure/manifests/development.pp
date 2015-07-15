package { "couchdb":
  ensure  => present,
}

class { "rbenv": }

rbenv::plugin { "sstephenson/ruby-build":
  latest => true
}

rbenv::build { "1.9.3-p194":
  global =>  true
}
