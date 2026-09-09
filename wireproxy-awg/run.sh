#!/usr/bin/with-contenv bashio

CONF=/data/wireproxy.conf
export WG_PRIVATE_KEY="$(bashio::config 'private_key')"
PSK="$(bashio::config 'preshared_key')"

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
  bashio::config.has_value 'awg_h1'   && echo "H1 = $(bashio::config 'awg_h1')"
  bashio::config.has_value 'awg_h2'   && echo "H2 = $(bashio::config 'awg_h2')"
  bashio::config.has_value 'awg_h3'   && echo "H3 = $(bashio::config 'awg_h3')"
  bashio::config.has_value 'awg_h4'   && echo "H4 = $(bashio::config 'awg_h4')"

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

bashio::log.info "Starting wireproxy..."
exec wireproxy -c "$CONF"