FROM ubuntu AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -qy build-essential git cmake

RUN git clone https://github.com/XboxDev/extract-xiso.git /extract-xiso && \
    mkdir /extract-xiso/build
WORKDIR /extract-xiso/build

# lol
RUN <<EOF
awk 'BEGIN{rc=1}
{
    if(/target_compile_definitions\(extract-xiso PRIVATE \$\{TARGET_OS\}\)/) {
        print "target_link_libraries(extract-xiso PRIVATE \"-static\")"
        rc=0
    }
    print $0
}
END{ exit rc }' ../CMakeLists.txt > ../CMakeLists.txt.new || echo "Patching for static linking failed"
EOF

RUN mv ../CMakeLists.txt.new ../CMakeLists.txt && \
    cmake .. && \
    make

FROM scratch
COPY --from=builder /extract-xiso/build/extract-xiso /extract-iso
ENTRYPOINT ["/extract-iso"]
