FROM golang:1.7-alpine
MAINTAINER Tom Denham <tom@projectcalico.org>

# Install su-exec for use in the entrypoint.sh (so processes run as the right user)
# Install bash for the entry script (and because it's generally useful)
# Install curl to download glide
# Install git for fetching Go dependencies
# Install wget for fetching glibc
# Install make for building things
RUN apk add --no-cache su-exec curl bash git make wget

# Install glibc
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
RUN apk add glibc-2.23-r3.apk

# Disable cgo so that binaries we build will be fully static.
ENV CGO_ENABLED=0

# Recompile the standard library with cgo disabled.  This prevents the standard library from being
# marked stale, causing full rebuilds every time.
RUN go install -v std

# Install glide
RUN curl https://glide.sh/get | sh
ENV GLIDE_HOME /home/user/.glide

# Install ginkgo CLI tool for running tests
RUN go get github.com/onsi/ginkgo/ginkgo

# Install linting tools
RUN go get -u github.com/alecthomas/gometalinter
RUN gometalinter --install

# Ensure that everything under the GOPATH is writable by everyone
RUN chmod -R 777 $GOPATH

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
