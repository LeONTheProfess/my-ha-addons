#!/usr/bin/with-contenv bashio

CONF=/data/wireproxy.conf
umask 077
export WG_PRIVATE_KEY="$(bashio::config 'private_key')"
PSK="$(bashio::config 'preshared_key')"
SILENT_FLAG="-s"

{
  echo "[Interface]"
  echo "Address = $(bashio::config 'address')"
  echo "PrivateKey = \$WG_PRIVATE_KEY"
  echo "DNS = $(bashio::config 'dns')"

  bashio::config.has_value 'awg_jc'   && echo "Jc = $(bashio::config 'awg_jc')"
  bashio::config.has_value 'awg_jmin' && echo "Jmin = $(bashio::config 'awg_jmin')"
  bashio::config.has_value 'awg_jmax' && echo "Jmax = $(bashio::config 'awg_jmax')"
  bashio::config.has_value 'awg_s1'   && echo "S1 = $(bashio::config 'awg_s1')"
  bashio::config.has_value 'awg_s2'   && echo "S2 = $(bashio::config 'awg_s2')"
  bashio::config.has_value 'awg_s3'   && echo "S3 = $(bashio::config 'awg_s3')"
  bashio::config.has_value 'awg_s4'   && echo "S4 = $(bashio::config 'awg_s4')"
  bashio::config.has_value 'awg_h1'   && echo "H1 = $(bashio::config 'awg_h1')"
  bashio::config.has_value 'awg_h2'   && echo "H2 = $(bashio::config 'awg_h2')"
  bashio::config.has_value 'awg_h3'   && echo "H3 = $(bashio::config 'awg_h3')"
  bashio::config.has_value 'awg_h4'   && echo "H4 = $(bashio::config 'awg_h4')"
  bashio::config.has_value 'awg_i1'   && echo "I1 = $(bashio::config 'awg_i1')"
  bashio::config.has_value 'awg_i2'   && echo "I2 = $(bashio::config 'awg_i2')"
  bashio::config.has_value 'awg_i3'   && echo "I3 = $(bashio::config 'awg_i3')"
  bashio::config.has_value 'awg_i4'   && echo "I4 = $(bashio::config 'awg_i4')"
  bashio::config.has_value 'awg_i5'   && echo "I5 = $(bashio::config 'awg_i5')"
  bashio::config.has_value 'awg_header_protection_key'    && echo "HeaderProtectionKey = $(bashio::config 'awg_header_protection_key')"
  bashio::config.has_value 'awg_content_padding_addition' && echo "ContentPaddingAddition = $(bashio::config 'awg_content_padding_addition')"
  bashio::config.has_value 'awg_rekey_after_time'  && echo "RekeyAfterTime = $(bashio::config 'awg_rekey_after_time')"
  bashio::config.has_value 'awg_rekey_timeout'     && echo "RekeyTimeout = $(bashio::config 'awg_rekey_timeout')"
  bashio::config.has_value 'awg_reject_after_time' && echo "RejectAfterTime = $(bashio::config 'awg_reject_after_time')"
  bashio::config.has_value 'awg_keepalive_timeout'      && echo "KeepaliveTimeout = $(bashio::config 'awg_keepalive_timeout')"
  bashio::config.has_value 'awg_max_handshake_attempts'  && echo "MaxHandshakeAttempts = $(bashio::config 'awg_max_handshake_attempts')"
  bashio::config.true 'debug_logging' && SILENT_FLAG=""



  if bashio::config.true 'awg_random_trailers'; then
    echo "RandomTrailers = on"
  fi
  if bashio::config.true 'awg_disable_cookies'; then
    echo "DisableCookies = on"
  fi

  echo ""
  echo "[Peer]"
  echo "PublicKey = $(bashio::config 'peer_public_key')"
  echo "Endpoint = $(bashio::config 'endpoint')"
  echo "PersistentKeepalive = $(bashio::config 'persistent_keepalive')"
  [ -n "$PSK" ] && echo "PresharedKey = $PSK"

  echo ""
  echo "[Socks5]"
  echo "BindAddress = $(bashio::config 'socks5_bind')"

  echo ""
  echo "[http]"
  echo "BindAddress = $(bashio::config 'http_bind')"
} > "$CONF"
chmod 600 "$CONF"

bashio::log.info "Starting wireproxy..."
exec wireproxy -c "$CONF" $SILENT_FLAG