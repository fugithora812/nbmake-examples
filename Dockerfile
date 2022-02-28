FROM jupyter/scipy-notebook:ubuntu-20.04

# install netbase
USER root
RUN apt update -y \
    && apt install -y netbase \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mamba install --quiet --yes git==2.35.0 \
    && conda clean -i -t -y

# install the notebook package etc.
RUN pip install --no-cache --upgrade pip \
    && pip install --no-cache nbmake
    
RUN jupyter contrib nbextension install --user \
    && jupyter nbextensions_configurator enable --user \
    && jupyter run-through quick-setup --user \
    && jupyter nbextension install --py lc_multi_outputs --user \
    && jupyter nbextension enable --py lc_multi_outputs --user

# install Japanese-font (for blockdiag)
ARG font_deb=fonts-ipafont-gothic_00303-18ubuntu1_all.deb
RUN mkdir ${HOME}/.fonts \
    && wget -P ${HOME}/.fonts http://archive.ubuntu.com/ubuntu/pool/universe/f/fonts-ipafont/${font_deb} \
    && dpkg-deb -x ${HOME}/.fonts/${font_deb} ~/.fonts \
    && cp ~/.fonts/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf ~/.fonts/ipag.ttf \
    && rm ${HOME}/.fonts/${font_deb} \
    && rm -rf ${HOME}/.fonts/etc ${HOME}/.fonts/usr \
    && rm .wget-hsts

ARG NB_USER=jovyan
ARG NB_UID=1000

RUN rm -rf ${HOME}/work

# prepare datalad procedure dir
RUN mkdir -p ${HOME}/.config/datalad/procedures

WORKDIR ${HOME}
COPY . ${HOME}

USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Specify the default command to run
# CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
