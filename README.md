# https-reverse-proxy
This project is packaged as a Docker image that will run a HAProxy reverse proxy with automated request and renewal of 
Let's Encrypt certificates. You only need to indicate your domains and endpoints in a simple YAML file.

## Usage
Clone this repository:
```
git clone https://github.com/brunneis/https-reverse-proxy
```

Edit the file `domains.yaml` with your domain names and endpoints. Each domain is represented with an object with a descriptive name for the key and two lists for the value: `domains` and `endpoints`. Add an item for each domain to the list `domains`. Add an endpoint with the structure `IP`:`PORT` for every listening endpoint to the list `endpoints`. The endpoints will be assigned following a Round-robin fashion.

```yaml
---
example1:
  domains:
    - example.com
    - www.example.com
  endpoints:
    - 10.0.0.10:10001
```

If your endpoint has SSL enabled, use the `ssl_endpoints` list instead of `endpoints`.
```yaml
---
example2:
  domains:
    - example.org
    - www.example.org
  ssl_endpoints:
    - 10.0.0.10:10002
```

Edit the file `env.sh` and change the value of the variable `LETSENCRYPT_EMAIL` to the email you want to be used for requesting the certificates.

Now, execute the `launch.sh` script. It will launch a Docker container, creating a `data` directory in the current directory and shared with the host to store the certificates persistently. Every day, the container will renew the certificates if needed.


## HAProxy advanced configuration
You can edit the `haproxy.yaml` file and change default general properties.

For example, the content:
```yaml
---
global:
  daemon:
  maxconn: 10000   
  tune.ssl.default-dh-param: 2048

defaults:
  mode: http
  timeout:
    connect: 60s
    client: 60s
    server: 60s
```

will generate the following `haproxy.cfg` header:
```
global
    daemon
    maxconn 10000
    tune.ssl.default-dh-param 2048

defaults
    mode http
    timeout connect 60s
    timeout client 60s
    timeout server 60s
```

