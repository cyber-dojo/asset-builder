
- A docker-containerized tool for [https://cyber-dojo.org](http://cyber-dojo.org).
- Builds a single CSS file from SCSS source files
- The implementation is a direct copy from dashboard - which needed updating to not convert the SCSS to CSS itself, 
because some of the sass libraries in its Dockerfile base-image (sinatra-base) were no longer being maintained, 
causing increasingly numerous snyk vulnerabilities. 
