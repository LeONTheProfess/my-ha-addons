# WireProxy AWG Home Assistant add-on

Home Assistant add-on that runs [WireProxy AWG](https://github.com/artem-russkikh/wireproxy-awg) as an AmneziaWG-compatible WireGuard client and exposes SOCKS5 and HTTP proxy endpoints.

## Origin and license

This project was originally taken from [artem-russkikh/wireproxy-awg](https://github.com/artem-russkikh/wireproxy-awg). The add-on packaging, Home Assistant configuration and startup integration in this repository are maintained separately.

The upstream project is licensed under ISC. See [LICENSE](LICENSE).

## Requirements

- Home Assistant OS or Supervised installation with add-on support.
- One of the supported architectures: `amd64`, `aarch64` or `armv7`.
- An AmneziaWG/WireGuard server configuration:
  - client private key;
  - client address, normally an IPv4 `/32` address;
  - server public key;
  - server endpoint such as `vpn.example.com:51820`.
- Access to `/dev/net/tun`. The add-on requests `NET_ADMIN` and the TUN device automatically.

## Installation

1. Open **Settings -> Add-ons -> Add-on store** in Home Assistant.
2. Open the menu in the upper-right corner and select **Repositories**.
3. Add this repository:

   `https://github.com/LeONTheProfess/my-ha-addons`

4. Find **WireProxy AWG** in the store and install it.
5. Open the add-on configuration, enter the required values, save, and start the add-on.

If the repository was already added before, remove the old repository URL containing `LeONTheProfes` and add the corrected URL above. Then refresh the add-on store so Home Assistant reads the current repository revision.

## Configuration

The minimum working configuration is:

```yaml
private_key: "YOUR_CLIENT_PRIVATE_KEY"
address: "10.200.200.2/32"
dns: "10.200.200.1"
peer_public_key: "SERVER_PUBLIC_KEY"
endpoint: "vpn.example.com:51820"
persistent_keepalive: "25"
socks5_bind: "0.0.0.0:25344"
http_bind: "0.0.0.0:25345"
```

Set the values in the add-on UI. Do not publish private keys or a saved add-on configuration in a public repository.

| Option | Required | Description |
| --- | --- | --- |
| `private_key` | Yes | WireGuard/AmneziaWG client private key. |
| `address` | Yes | Client tunnel address, for example `10.200.200.2/32`. |
| `dns` | Yes | DNS server used by the WireProxy configuration. |
| `peer_public_key` | Yes | Public key of the WireGuard server. |
| `endpoint` | Yes | Server hostname or IP and port. |
| `preshared_key` | No | Optional WireGuard preshared key. |
| `persistent_keepalive` | No | Keepalive interval in seconds; ranges such as `15-25` are supported. |
| `socks5_bind` | Yes | SOCKS5 listen address. Default: `0.0.0.0:25344`. |
| `http_bind` | Yes | HTTP proxy listen address. Default: `0.0.0.0:25345`. |

### AmneziaWG options

The following optional fields are passed to the `[Interface]` section using the same names as the upstream project:

| Options | Meaning |
| --- | --- |
| `awg_jc`, `awg_jmin`, `awg_jmax` | Junk packet count and size limits. |
| `awg_s1` - `awg_s4` | AmneziaWG packet padding values. |
| `awg_h1` - `awg_h4` | AmneziaWG handshake message types. |
| `awg_i1` - `awg_i5` | Custom packet tag sequences. |
| `awg_header_protection_key` | Header protection key. |
| `awg_content_padding_addition` | Additional content padding or range. |
| `awg_rekey_after_time` | Rekey interval or range in seconds. |
| `awg_rekey_timeout` | Handshake retry timeout or range in seconds. |
| `awg_reject_after_time` | Key rejection timeout or range in seconds. |
| `awg_keepalive_timeout` | Idle keepalive timeout or range in seconds. |
| `awg_max_handshake_attempts` | Maximum handshake attempts or range. |
| `awg_random_trailers` | Enable random packet trailers. |
| `awg_disable_cookies` | Disable WireGuard cookie replies. |

Use values supplied by your AmneziaWG server administrator. The server must support the selected AmneziaWG features; otherwise the tunnel may fail to establish.

## Using the proxy

After the add-on starts, clients on the configured bind address can use:

- SOCKS5: `socks5://home-assistant-host:25344`
- HTTP: `http://home-assistant-host:25345`

For a local-only proxy, use `127.0.0.1:25344` and `127.0.0.1:25345` in the add-on configuration instead of `0.0.0.0`. The add-on does not provide proxy username/password authentication. Do not expose these ports to an untrusted network.

The add-on exposes ports `25344/tcp` and `25345/tcp`. Home Assistant port mappings can be changed in the add-on network settings if these host ports are already in use.

## Troubleshooting

1. Open the add-on **Log** tab and check the generated WireProxy startup error.
2. Confirm that the private key, server public key and endpoint are copied without extra spaces.
3. Confirm that the endpoint UDP port is reachable from the Home Assistant host.
4. Check that the client address does not overlap another network.
5. If AmneziaWG options are enabled, compare every value with the server configuration and temporarily disable optional AWG fields to isolate the problem.
6. Verify that `/dev/net/tun` exists on the host and that the installation supports add-ons.

The generated configuration is stored inside the add-on at `/data/wireproxy.conf` and is recreated on every start from the add-on options.

## Development and validation

The Go source is the upstream WireProxy AWG source kept in this repository for tests and for building the add-on image. Run these checks from `wireproxy-awg/`:

```bash
go test ./...
make
```

The Home Assistant image is built from `Dockerfile`; there is no `build.yaml` or `build.json` in the current project. The binary source version is pinned in `Dockerfile` through `WIREPROXY_VERSION`.
