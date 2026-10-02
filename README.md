Some cyber-dojo microservice docker images (creator, dashboard, web) need compiled CSS/JS.
Compiling it inside each image pulled SCSS/JS gems into their sinatra base image,
and snyk vulnerabilities piled up there.

asset-builder does the compiling as a pre-build step instead, so the microservice
Dockerfiles can use a sinatra base image without those gems.

It owns its compilation gems directly (see source/Gemfile):
- sprockets: the asset pipeline
- sassc-embedded: SCSS, rendered by Dart Sass (supports @use)
- uglifier + mini_racer: JS compression on V8, with no node binary
