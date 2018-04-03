# oradb_ext

## Description

This is a EuPathDB BRC extension of the `biemond-oradb` puppet module.
It provides additional management of Oracle RDMS that `oradb` does not.

This is not supported outside EuPathDB BRC.

## Classes

#### `oradb_ext::systemd`

Installs systemd service files to start Oracle listener and database
server. This class defaults to **not** enabling systemd managment of
oracle services. So if you only `include oradb_ext::systemd` in a
manifest nothing will change. To enable, also set in hiera:

    oradb_ext::systemd::enable: true 

This helps prevent accidental setup on production systems.

The `oralsnr` service is a dependency of the `oradb` service so it is
sufficient to manage `oradb`.

    systemctl start oradb
    systemctl stop oradb
    systemctl status oradb

Understand that `oradb` only starts/stops databases marked to be
autostarted in `/etc/oratab`. This class does not manage the oratab file.

