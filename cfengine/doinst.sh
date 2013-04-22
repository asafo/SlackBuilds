config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

config_ld() {
  grep cfengine /etc/ld.so.conf > /dev/null
  if [ ! $? -eq 0  ]; then
    echo "/var/cfengine/lib" >> /etc/ld.so.conf
    echo "Updating shared library links.."
    /sbin/ldconfig
  fi
}

preserve_perms etc/rc.d/rc.cfengine.new
config etc/logrotate.d/cfengine.new
config_ld
