---
author: "Rodrigo Dumont"
date: 2017-11-10
title: "Profile Go micro-services in Kubernetes with pprof"
tags: [ go, pprof, kubernetes, gin ]
highlight: true
---

One of Go's most life-saving features is its native profiling tool, `pprof`. It enables you to **instrument your code** in order to discover problems related to **performance, concurrency and memory usage**.

I've read a few articles on how to set up the instrumentation, run the tool and analyze its results, but the examples usually work on your machine. Using it on code that is **deployed on a Kubernetes cluster** takes a few more steps, and this is how I did it.

## Instrumentation

The first thing is to reference `net/http/pprof`, usually in my `main.go` file:

```golang
package main

import (
    "net/http"
    _ "net/http/pprof"
)

func main() {
    http.HandleFunc("/", serveHTTP)
    http.ListenAndServe(":8080", nil)
}

func serveHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello, world"))
}
```

The above code, by importing `net/http/pprof`, registers a few profiling endpoints to the default HTTP mux. Unfortunately that is probably not what most of us use in production. So instead, I set up the router to handle every request to `/debug/*` by redirecting it to the default mux. Below are a few options, depending on the router.

### HTTP serve mux

```go
func main() {
    r := http.NewServeMux()
    r.HandleFunc("/", serveHTTP)

    r.Handle("/debug/", http.DefaultServeMux)
    http.ListenAndServe(":8080", r)
}
```

### [gorilla/mux](https://github.com/gorilla/mux)

```go
func main() {
    r := mux.NewRouter()
    r.HandleFunc("/", serveHTTP)

    r.Handle("/debug/", http.DefaultServeMux)
    http.ListenAndServe(":8080", r)
}
```

### [Gin](https://github.com/gin-gonic/gin)

```go
func main() {
	r := gin.New()
	r.GET("/", serveHTTP)

	r.Any("/debug/*path", gin.WrapH(http.DefaultServeMux))

	http.ListenAndServe(":8080", r)
}
```

The same concept could be used for other routers.

## Web interface

This first method of profiling gives us a web page, accessible through a browser, with a snapshot of some key items about the current Go program. In order to access it, I'm going to **forward a port**[^1] from the pod to my machine.

1. `kubectl get pods` provides me with a list of all pods in order to find the desired name
2. `kubectl port-forward <pod_name> <local_port>:<container_port>` allows me to access `local_port` being forwarded to the pod's `container_port`

Now I'm able to go to `http://localhost:<local_port>/debug/pprof/` on my web browser to see something that looks like the following:

```
/debug/pprof/

profiles:
0	block
4	goroutine
2	heap
0	mutex
7	threadcreate

full goroutine stack dump
```

By clicking any of the profiles, you're taken to a detailed view of each of them. This is nice to get a quick overview of what's going on and might show you, for instance, deadlocks and growing goroutine count. But for the most powerful visualization I like to use `go tool pprof instead`.

## Command line interface

The purpose of this article is to show you how to put together everything that you might need to profile in production inside of a Kubernetes cluster, so I won't go into too much detail about `pprof` itself. The official documentation and release post provide plenty of examples of how to use the tool. [^2] [^3]

1. Retrieve the binary (just skip to the next step if you already have it)

    ```
    kubectl cp <pod_name>:<binary_path_in_pod> <local_binary_path>
    ```

2. Run `pprof`

    ```
    # Get a 30 second CPU profile
    go tool pprof <local_binary_path> 'http://localhost:<local_port>/debug/pprof/profile'

    # Get a 60 second CPU profile
    go tool pprof <local_binary_path> 'http://localhost:<local_port>/debug/pprof/profile?seconds=60'

    # Get a heap profile
    go tool pprof <local_binary_path> 'http://localhost:<local_port>/debug/pprof/heap'
    ```

After running the command, it will go into an interactive mode with various options. I recommend you type `help` to find out what they are and to see the tool's online reference.


[^1]: [Use Port Forwarding to Access Applications in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)
[^2]: [`net/http/pprof` Godoc](https://golang.org/src/net/http/pprof/pprof.go)
[^3]: [Profiling Go Programs](https://blog.golang.org/2011/06/profiling-go-programs.html). 24 June 2011.

