## Host machine

All the steps below are to be ran from the host machine, not the virtual machines.

### Private docker registry

Run a private Docker image registry. 

```sh
$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v registry:/var/lib/registry \
  registry:2
Unable to find image 'registry:2' locally
2: Pulling from library/registry
169185f82c45: Pull complete
046e2d030894: Pull complete
188836fddeeb: Pull complete
832744537747: Pull complete
7ceea07e80be: Pull complete
Digest: sha256:870474507964d8e7d8c3b53bcfa738e3356d2747a42adad26d0d81ef4479eb1b
Status: Downloaded newer image for registry:2
01edbbd8b65abaedcf9308fb36bed275a3498d7265736ea505aca47f1b3d3518
```

### Build a docker image

Build a docker image of the ruby application on the host machine and push it to private registry.

Our ruby application:
* listens for http on `*:8080`
* expects to connect and ping a Redis server at: `redis:6379`

```
$ docker build -t ruby-app .
Sending build context to Docker daemon  316.9kB
Step 1/7 : FROM ruby:alpine
alpine: Pulling from library/ruby
6c40cc604d8e: Pull complete
4e0e4ac8c025: Pull complete
9a13ad0cfe1d: Pull complete
16f42435de28: Pull complete
Digest: sha256:8b3dd24063423797b27407f5bd5f475796ff6e786cad00d8a0927cd472c2d3be
Status: Downloaded newer image for ruby:alpine
  ---> 708614d8fa07
Step 2/7 : ADD ./ruby /
  ---> 2441a57d28f5
Step 3/7 : WORKDIR /
  ---> Running in 47b86af133fe
Removing intermediate container 47b86af133fe
  ---> 113e9c61d115
Step 4/7 : RUN apk --no-cache add --virtual build-deps g++ musl-dev make
  ---> Running in 2afc04dc5295
...
Step 7/7 : CMD ["ruby", "server.rb"]
  ---> Running in 50a3444be29e
Removing intermediate container 50a3444be29e
  ---> 1035103b18c8
Successfully built 1035103b18c8
Successfully tagged ruby-app:latest

$ docker image tag ruby-app localhost:5000/ruby-app

$ docker push localhost:5000/ruby-app
The push refers to repository [localhost:5000/ruby-app]
0aef3311492d: Pushed
0471056ed6bc: Pushed
70c4009aa202: Layer already exists
6c6387f7f161: Pushed
d7cf4b2f58ee: Pushed
5261915d5644: Pushed
503e53e365f3: Pushed
latest: digest: sha256:b4193d078282ce44f300a659abe25317781e2ff20bc4b4576e9c4ddfb302354e size: 1785
```

## Validate docker images

```
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE
ruby-app                  latest              1035103b18c8        About a minute ago   239MB
localhost:5000/ruby-app   latest              1035103b18c8        About a minute ago   239MB
ruby                      alpine              708614d8fa07        3 days ago           47.4MB
registry                  2                   d0eed8dad114        5 days ago           25.8MB
```
