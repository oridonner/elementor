FROM bitnami/kafka:3.6.0
USER root

RUN apt-get update &&                                                                   \
    apt-get install -y sysstat &&                                                       \
    apt-get install -y unzip &&                                                         \
    rm -rf /var/lib/apt/lists/* 

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&    \
    unzip awscliv2.zip &&                                                                   \
    ./aws/install &&                                                                        \
    rm -rf awscliv2.zip /var/lib/apt/lists/*
# USER 1001