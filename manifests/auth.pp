class dovecot::auth (
  $disable_plaintext_auth = 'no',
  $auth_mechanisms        = 'plain login',
  $auth_username_format   = '%Ln',
  $auth_default_realm     = "${::fqdn}",
  $auth_gssapi_hostname   = undef,
  $auth_krb5_keytab       = undef,

) {
  include dovecot

  dovecot::config::dovecotcfmulti { 'auth':
    config_file => 'conf.d/10-auth.conf',
    changes     => [
      "set disable_plaintext_auth '${disable_plaintext_auth}'",
      "set auth_mechanisms '${auth_mechanisms}'",
      "set auth_username_format '${auth_username_format}'",
      "set auth_default_realm '${auth_default_realm}'",
    ],
  }

  dovecot::config::dovecotcfsingle { 'auth_gssapi_hostname':
    ensure      => $auth_gssapi_hostname ? { undef => absent, default => present },
    config_file => 'conf.d/auth.conf',
    value       => $auth_gssapi_hostname
  }
  dovecot::config::dovecotcfsingle { 'auth_krb5_keytab':
    ensure      => $auth_krb5_keytab ? { undef => absent, default => present },
    config_file => 'conf.d/auth.conf',
    value       => $auth_krb5_keytab
  }
}
