# ------------------------ Golang ---------------------------
FROM golang:1.17-alpine AS golang

# 環境変数設定
ENV ROOT=/go/src/app

WORKDIR ${ROOT}

RUN apk update && apk add git

RUN go install golang.org/x/tools/cmd/goimports@latest \
    && go install golang.org/x/tools/gopls@latest \
    && go install golang.org/x/tools/cmd/godoc@latest \
    && go install golang.org/x/lint/golint@latest \
    && go install github.com/rogpeppe/godef@latest \
    && go install github.com/nsf/gocode@latest \
    # hot relord
    && go install github.com/cosmtrek/air@latest \
    # debug
    && go install github.com/go-delve/delve/cmd/dlv@latest

ADD ./server/shell/mysqldef.sh ${ROOT}/shell/mysqldef.sh

RUN sh ${ROOT}/shell/mysqldef.sh

# GO MODULEインストール
COPY ./server/go.mod .
COPY ./server/go.sum .
RUN go mod download

# # ------------------------ Node ---------------------------
FROM node:14-alpine as node

# # ------------------------ Develop ---------------------------
FROM alpine as dev

# 環境変数設定(GO)
ENV GOPATH=/root/go
ENV PATH $PATH:/usr/local/go/bin/:/usr/local/go/bin/go:/go/bin
ENV GO111MODULE=on

WORKDIR /app

RUN apk update && \
    apk add --no-cache && \
    apk add curl && \
    apk add tzdata && \
    apk add git && \
    apk add openssh && \
    apk add make

# Golang用
COPY --from=golang /usr/local/bin /usr/local/bin
COPY --from=golang /usr/local/go /usr/local/go
COPY --from=golang /go/bin /go/bin
COPY --from=golang /go/pkg ${GOPATH}/pkg

# Node.js用
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm
COPY --from=node /opt/yarn* /opt/yarn

RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

# Gin Port
EXPOSE 8080
# Next.js Port
EXPOSE 3000