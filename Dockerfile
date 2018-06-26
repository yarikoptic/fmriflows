# Generated by Neurodocker version 0.4.0
# Timestamp: 2018-06-26 15:32:34 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/kaczmarj/neurodocker

FROM neurodebian:stretch-non-free

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           gcc \
           g++ \
           graphviz \
           tree \
           less \
           swig \
           convert3d \
           git-annex-standalone \
           git-annex-remote-rclone \
           texlive-latex-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FORCE_SPMMCR="1" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu:/opt/matlabmcr-2018a/v94/runtime/glnxa64:/opt/matlabmcr-2018a/v94/bin/glnxa64:/opt/matlabmcr-2018a/v94/sys/os/glnxa64:/opt/matlabmcr-2018a/v94/extern/bin/glnxa64" \
    MATLABCMD="/opt/matlabmcr-2018a/v94/toolbox/matlab"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           libxext6 \
           libxpm-dev \
           libxt6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "Downloading MATLAB Compiler Runtime ..." \
    && curl -fsSL --retry 5 -o /tmp/mcr.zip https://ssd.mathworks.com/supportfiles/downloads/R2018a/deployment_files/R2018a/installers/glnxa64/MCR_R2018a_glnxa64_installer.zip \
    && unzip -q /tmp/mcr.zip -d /tmp/mcrtmp \
    && /tmp/mcrtmp/install -destinationFolder /opt/matlabmcr-2018a -mode silent -agreeToLicense yes \
    && rm -rf /tmp/* \
    && echo "Downloading standalone SPM ..." \
    && curl -fsSL --retry 5 -o /tmp/spm12.zip http://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/dev/spm12_latest_Linux_R2018a.zip \
    && unzip -q /tmp/spm12.zip -d /tmp \
    && mkdir -p /opt/spm12-dev \
    && mv /tmp/spm12/* /opt/spm12-dev/ \
    && chmod -R 777 /opt/spm12-dev \
    && rm -rf /tmp/* \
    && /opt/spm12-dev/run_spm12.sh /opt/matlabmcr-2018a/v94 quit \
    && sed -i '$iexport SPMMCRCMD=\"/opt/spm12-dev/run_spm12.sh /opt/matlabmcr-2018a/v94 script\"' $ND_ENTRYPOINT

ENV ANTSPATH="/opt/ants-2.2.0" \
    PATH="/opt/ants-2.2.0:$PATH"
RUN echo "Downloading ANTs ..." \
    && mkdir -p /opt/ants-2.2.0 \
    && curl -fsSL --retry 5 https://dl.dropbox.com/s/2f4sui1z6lcgyek/ANTs-Linux-centos5_x86_64-v2.2.0-0740f91.tar.gz \
    | tar -xz -C /opt/ants-2.2.0 --strip-components 1

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           fsl-core \
           fsl-harvard-oxford-atlases \
           fsl-harvard-oxford-cortical-lateralized-atlas \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i '$isource /etc/fsl/fsl.sh' $ND_ENTRYPOINT

RUN useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"
RUN export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && sync && conda clean -tipsy && sync \
    && conda create -y -q --name neuro \
    && conda install -y -q --name neuro \
           python=3.6 \
           ipython \
           pytest \
           jupyter \
           jupyterlab \
           jupyter_contrib_nbextensions \
           numpy \
           scipy \
           pandas \
           matplotlib \
           seaborn \
           nipy \
           pyface \
           sphinx \
           h5py \
           joblib \
           traits \
           scikit-learn \
           scikit-image \
           nbformat \
           nb_conda \
           statsmodels \
    && sync && conda clean -tipsy && sync \
    && bash -c "source activate neuro \
    &&   pip install  --no-cache-dir \
             https://github.com/nipy/nipype/tarball/master \
             https://github.com/INCF/pybids/tarball/master \
             nibabel \
             nilearn \
             nitime \
             pymvpa2 \
             datalad[full] \
             nipy \
             duecredit \
             nbval" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate neuro' $ND_ENTRYPOINT

USER root

RUN mkdir /data && chmod 777 /data && chmod a+s /data

RUN mkdir /output && chmod 777 /output && chmod a+s /output

RUN mkdir /templates && chmod 777 /templates && chmod a+s /templates

RUN curl -qLO http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_asym_09c_nifti.zip \
                         && unzip mni_icbm152_nlin_asym_09c_nifti.zip -d /templates \
                         && rm mni_icbm152_nlin_asym_09c_nifti.zip \
                         && cd /templates/mni_icbm152_nlin_asym_09c \
                      && mv mni_icbm152_csf_tal_nlin_asym_09c.nii 1.0mm_tpm_csf.nii \
                         && mv mni_icbm152_gm_tal_nlin_asym_09c.nii 1.0mm_tpm_gm.nii \
                         && mv mni_icbm152_pd_tal_nlin_asym_09c.nii 1.0mm_PD.nii \
                         && mv mni_icbm152_t1_tal_nlin_asym_09c_mask.nii 1.0mm_mask.nii \
                         && mv mni_icbm152_t1_tal_nlin_asym_09c.nii 1.0mm_T1.nii \
                         && mv mni_icbm152_t2_tal_nlin_asym_09c.nii 1.0mm_T2.nii \
                         && mv mni_icbm152_wm_tal_nlin_asym_09c.nii 1.0mm_tpm_wm.nii \
                         && gzip 1.0mm_*nii \
                         && /usr/bin/fsl5.0-fslmaths 1.0mm_tpm_gm.nii.gz -add 1.0mm_tpm_wm.nii.gz -add 1.0mm_tpm_csf.nii.gz 1.0mm_brain_prob_mask.nii.gz \
                         && /usr/bin/fsl5.0-fslmaths 1.0mm_T1.nii.gz -mul 1.0mm_mask.nii.gz 1.0mm_brain.nii.gz

COPY ["scripts/templates/HarvardOxford_labels.csv", "scripts/templates/parcellate_HarvardOxford.py", "scripts/templates/resample_icbm152.py", "/templates/"]

COPY ["notebooks", "/home/neuro/notebooks"]

COPY ["examples", "/home/neuro/examples"]

COPY ["scripts/test_notebooks.py", "/home/neuro/test_notebooks.py"]

RUN chown -R neuro /home/neuro

RUN chown -R neuro /templates

RUN rm -rf /opt/conda/pkgs/*

USER neuro

RUN mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"*\" > ~/.jupyter/jupyter_notebook_config.py

WORKDIR /home/neuro/notebooks

CMD ["jupyter-notebook"]

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "neurodebian:stretch-non-free" \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "gcc", \
    \n        "g++", \
    \n        "graphviz", \
    \n        "tree", \
    \n        "less", \
    \n        "swig", \
    \n        "convert3d", \
    \n        "git-annex-standalone", \
    \n        "git-annex-remote-rclone", \
    \n        "texlive-latex-base" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "spm12", \
    \n      { \
    \n        "version": "dev" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "ants", \
    \n      { \
    \n        "version": "2.2.0", \
    \n        "method": "binaries" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "fsl-core", \
    \n        "fsl-harvard-oxford-atlases", \
    \n        "fsl-harvard-oxford-cortical-lateralized-atlas" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "add_to_entrypoint", \
    \n      "source /etc/fsl/fsl.sh" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "miniconda_version": "4.5.4", \
    \n        "conda_install": [ \
    \n          "python=3.6", \
    \n          "ipython", \
    \n          "pytest", \
    \n          "jupyter", \
    \n          "jupyterlab", \
    \n          "jupyter_contrib_nbextensions", \
    \n          "numpy", \
    \n          "scipy", \
    \n          "pandas", \
    \n          "matplotlib", \
    \n          "seaborn", \
    \n          "nipy", \
    \n          "pyface", \
    \n          "sphinx", \
    \n          "h5py", \
    \n          "joblib", \
    \n          "traits", \
    \n          "scikit-learn", \
    \n          "scikit-image", \
    \n          "nbformat", \
    \n          "nb_conda", \
    \n          "statsmodels" \
    \n        ], \
    \n        "pip_install": [ \
    \n          "https://github.com/nipy/nipype/tarball/master", \
    \n          "https://github.com/INCF/pybids/tarball/master", \
    \n          "nibabel", \
    \n          "nilearn", \
    \n          "nitime", \
    \n          "pymvpa2", \
    \n          "datalad[full]", \
    \n          "nipy", \
    \n          "duecredit", \
    \n          "nbval" \
    \n        ], \
    \n        "create_env": "neuro", \
    \n        "activate": true \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "root" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /data && chmod 777 /data && chmod a+s /data" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /output && chmod 777 /output && chmod a+s /output" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /templates && chmod 777 /templates && chmod a+s /templates" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "curl -qLO http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_asym_09c_nifti.zip \\\\n                  && unzip mni_icbm152_nlin_asym_09c_nifti.zip -d /templates \\\\n                  && rm mni_icbm152_nlin_asym_09c_nifti.zip \\\\n                  && cd /templates/mni_icbm152_nlin_asym_09c\\n                  && mv mni_icbm152_csf_tal_nlin_asym_09c.nii 1.0mm_tpm_csf.nii \\\\n                  && mv mni_icbm152_gm_tal_nlin_asym_09c.nii 1.0mm_tpm_gm.nii \\\\n                  && mv mni_icbm152_pd_tal_nlin_asym_09c.nii 1.0mm_PD.nii \\\\n                  && mv mni_icbm152_t1_tal_nlin_asym_09c_mask.nii 1.0mm_mask.nii \\\\n                  && mv mni_icbm152_t1_tal_nlin_asym_09c.nii 1.0mm_T1.nii \\\\n                  && mv mni_icbm152_t2_tal_nlin_asym_09c.nii 1.0mm_T2.nii \\\\n                  && mv mni_icbm152_wm_tal_nlin_asym_09c.nii 1.0mm_tpm_wm.nii \\\\n                  && gzip 1.0mm_*nii \\\\n                  && /usr/bin/fsl5.0-fslmaths 1.0mm_tpm_gm.nii.gz -add 1.0mm_tpm_wm.nii.gz -add 1.0mm_tpm_csf.nii.gz 1.0mm_brain_prob_mask.nii.gz \\\\n                  && /usr/bin/fsl5.0-fslmaths 1.0mm_T1.nii.gz -mul 1.0mm_mask.nii.gz 1.0mm_brain.nii.gz" \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "scripts/templates/HarvardOxford_labels.csv", \
    \n        "scripts/templates/parcellate_HarvardOxford.py", \
    \n        "scripts/templates/resample_icbm152.py", \
    \n        "/templates/" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "notebooks", \
    \n        "/home/neuro/notebooks" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "examples", \
    \n        "/home/neuro/examples" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        "scripts/test_notebooks.py", \
    \n        "/home/neuro/test_notebooks.py" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "chown -R neuro /home/neuro" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "chown -R neuro /templates" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "rm -rf /opt/conda/pkgs/*" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \\\"*\\\" > ~/.jupyter/jupyter_notebook_config.py" \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/home/neuro/notebooks" \
    \n    ], \
    \n    [ \
    \n      "cmd", \
    \n      [ \
    \n        "jupyter-notebook" \
    \n      ] \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json
