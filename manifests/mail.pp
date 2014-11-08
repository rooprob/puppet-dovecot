class dovecot::mail (
  $username           = 'vmail',
  $groupname          = 'vmail',
  $gid                = 5000,
  $uid                = 5000,
  $first_valid_uid    = 5000,
  $last_valid_uid     = 5000,
  $first_valid_gid    = 5000,
  $last_valid_gid     = 5000,
  $manage_mailboxfile = false,
  $mailboxtemplate    = 'dovecot/15-mailboxes.conf',
  $mailstoretype      = 'maildir',
  $userhome           = '/srv/vmail',
  $mailstorepath      = '/srv/vmail/%d/%n/',
  $mailplugins        = 'quota',
) {
  include dovecot

  dovecot::config::dovecotcfsingle { 'mail_location':
    config_file => 'conf.d/10-mail.conf',
    value       => "${mailstoretype}:${mailstorepath}",
  }

  if $manage_mailboxfile {
    dovecot::config::dovecotcfmulti { 'mail':
      config_file => 'conf.d/10-mail.conf',
      changes     => [
        "set mail_uid ${uid}",
        "set mail_gid ${gid}",
        "set first_valid_uid ${first_valid_uid}",
        "set last_valid_uid  ${last_valid_uid}",
        "set first_valid_gid ${first_valid_gid}",
        "set last_valid_gid ${last_valid_gid}",
        "set mail_plugins '${$mailplugins}'",
      ],
    }
    group { $groupname :
      ensure => present,
      gid    => $gid,
    }

    user { $username:
      ensure     => present,
      gid        => $gid,
      home       => $userhome,
      managehome => false,
      uid        => $uid,
      require    => Group[$groupname]
    }

    file { $userhome:
      ensure  => directory,
      owner   => $username,
      group   => $groupname,
      mode    => '0750',
      require => User[$username],
    }
    file { '/etc/dovecot/conf.d/15-mailboxes.conf':
      ensure  => present,
      content => template($mailboxtemplate),
      mode    => '0644',
      owner   => root,
      group   => root,
      before  => Exec['dovecot'],
    }
  }
}
