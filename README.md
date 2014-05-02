# Tor/Delegate/Haproxy a Docker Project #

The purpose of this project is to provide an image that you can you to have a pool of rotating ips through tor, delegate and haproxy.
This image will setup 10 tor, 10 delegate (one for each tor) and Haproxy to manage all that which expose port 9100.

## Building docker-tor

Running this will build you a docker image with the latest version of both
docker-teamspeak and TeamSpeak itself.

    git clone https://github.com/srounet/docker-tor
    cd docker-tor
    docker build -t srounet/tor .

## Running docker-tor

Running the first time will set your port to a static port of your choice so
that you can easily map a proxy to. If this is the only thing running on your
system you can map the port to 9100 and no proxy is needed. i.e.
`-p=9100:9100`.

    sudo docker run -d=true -p=9100:9100 srounet/docker-tor ./start.sh

### Notes on the run command

 + `srounet/docker-tor` is simply what I called my docker build of this image
 + `-d=true` allows this to run cleanly as a daemon, remove for debugging
 + `-p` is the port it connects to, `-p=host_port:docker_port`

### Test it with python

```python
import requests
proxies = {'http': 'http://localhost:9100'}

# Should print your real ip
response = requests.get('http://jsonip.com')
print response.json()

# Should print an ip from tor network
response = requests.get('http://jsonip.com', proxies=proxies)
print response.json()

# Should print another ip from tor network
response = requests.get('http://jsonip.com', proxies=proxies)
print response.json()
```


### Side notes

This Readme is inspired by overshard/docker-teamspeak docker project.
