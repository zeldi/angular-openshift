## Creating and Deploying Angular Apps on Openshift

1. Create Sample Angular-App

```bash
$ ng new myangular-app
```

2. Create Nginx default configuration (``default.conf``)

We will configure Nginx to listen on port 8080

```bash
$ cd myangular-app
$ vi default.conf
server {
    listen       8080;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```


3. Create ``Dockerfile`` to myangular-app folder

```yaml
# stage 1
FROM node:latest as node
WORKDIR /app
COPY . .
RUN npm install
ARG env=prod
RUN npm run build --prod

# stage 2
FROM nginx:alpine
COPY --from=node /app/dist/ /usr/share/nginx/html
COPY --from=node /app/default.conf /etc/nginx/conf.d/
EXPOSE 8080
```

4. Push folder ``myangular-app`` to Git repo (e.g. https://github.com/zeldi/myangular)

```
# git push -u origin master
```

5. Deploy Angular App to openshift

```bash
# oc new-app https://github.com/zeldi/myangular.git --name angular-app
warning: Cannot check if git requires authentication.
--> Found Docker image 377c083 (2 weeks old) from Docker Hub for "nginx:alpine"

    * An image stream tag will be created as "nginx:alpine" that will track the source image
    * A Docker build using source code from https://github.com/zeldi/myangular.git will be created
      * The resulting image will be pushed to image stream tag "welcome:latest"
      * Every time "nginx:alpine" changes a new build will be triggered
      * WARNING: this source repository may require credentials.
                 Create a secret with your git credentials and use 'set build-secret' to assign it to the build config.
    * This image will be deployed in deployment config "welcome"
    * Port 8080/tcp will be load balanced by service "welcome"
      * Other containers can access this service through the hostname "welcome"
    * WARNING: Image "nginx:alpine" runs as the 'root' user which may not be permitted by your cluster administrator

--> Creating resources ...
    imagestream.image.openshift.io "nginx" created
    imagestream.image.openshift.io "angular-app" created
    buildconfig.build.openshift.io "angular-app" created
    deploymentconfig.apps.openshift.io "angular-app" created
    service "welcome" created
--> Success
    Build scheduled, use 'oc logs -f bc/welcome' to track its progress.
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/angular-app'
    Run 'oc status' to view your app.

```

Alternatively, we deploy from directly from local folder.

```bash
$ cd myangular-app
$ oc new-app . --strategy=docker
```


6. Check POD

```bash
$ oc get pod
NAME              READY     STATUS      RESTARTS   AGE
angular-app-1-build   0/1       Completed   0          38m
angular-app-1-sdtx6   1/1       Running     0          35m
```
