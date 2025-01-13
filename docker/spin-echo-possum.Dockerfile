# DW-POSSUM with spin-echo sequences, FSL version 5.0.10.

# DWI POSSUM extension scripts:
# <https://github.com/marksgraham/DW-POSSUM>
# Spin-echo extension code:
# <https://github.com/marksgraham/spin-echo-POSSUM>
# Archive reference for old compilation instructions:
# <http://web.archive.org/web/20200220112757/https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation/SourceCode>
FROM gcc:4.9

ARG FSL_VERSION="5.0.10"
ENV FSLDIR="/usr/local/fsl"
ENV FSLDEVDIR="/opt/fsl-dev"
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

RUN rm /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian/ jessie main" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian/ jessie main" | tee -a /etc/apt/sources.list
RUN echo "Acquire::Check-Valid-Until false;" | tee -a /etc/apt/apt.conf.d/10-nocheckvalid && \
    echo "Acquire::AllowInsecureRepositories true;" | tee -a /etc/apt/apt.conf.d/10-nocheckvalid && \
    echo "Acquire::AllowDowngradeToInsecureRepositories true;" | tee -a /etc/apt/apt.conf.d/10-nocheckvalid && \
    echo "APT::Get::AllowUnauthenticated true;" | tee -a /etc/apt/apt.conf.d/10-nocheckvalid
RUN echo 'Package: *\nPin: origin "archive.debian.org"\nPin-Priority: 500' | tee -a /etc/apt/preferences.d/10-archive-pin
RUN apt-mark hold libc6 g++

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes --quiet --no-install-recommends \
    apt-utils       \
    python3         \
    make            \
    wget            \
    file            \
    dc              \
    tzdata          \
    expat           \
    software-properties-common \
    nano           \
    libquadmath0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/ginstall ginstall /usr/bin/install 1

RUN mkdir --parents /opt/fsl-dev/
WORKDIR /opt/fsl-dev/

RUN wget https://git.fmrib.ox.ac.uk/fsl/installer/-/raw/3.3.0/fslinstaller.py \
    --no-check-certificate && \
    python3 fslinstaller.py -p -D \
    --fslversion=$FSL_VERSION \
    -d /usr/local/fsl

ENV PATH="${FSLDEVDIR}/bin/:${PATH}"

RUN git clone https://github.com/marksgraham/spin-echo-POSSUM.git && \
    cp -r spin-echo-POSSUM/* "${FSLDIR}/src/possum/"

ENTRYPOINT [ "sh", "-c", ". /usr/local/fsl/etc/fslconf/fsl.sh && . /usr/local/fsl/etc/fslconf/fsl-devel.sh && /bin/bash" ]
