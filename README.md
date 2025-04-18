
Many cyber-dojo microservice docker images (eg saver, differ) use a sinatra base image in their Dockerfile. 
This base image adds SCSS/JS Gems, some of which have fallen into disuse. 
This is causing snyk vulnerabilities to accumulate in the microservice images. 
This repo uses the same sinatra base image with old Gems, but can be used to create the
required CSS/JS files as a pre-build step in these microservices, thus allowing their
Dockerfiles to upgrade to a new sinatra base image, without the SCSS/JS Gems, and respond to snyk vulnerabilities.
Then the asset-builder can be re-implemented using, eg, node.
