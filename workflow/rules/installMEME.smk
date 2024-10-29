rule downloadMEME:
    output:
        index='software/meme-5.5.7.tar.gz'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        wget https://meme-suite.org/meme/meme-software/5.5.7/meme-5.5.7.tar.gz
        tar zxf meme-5.5.7.tar.gz
        (cd meme-5.5.7 && ./configure --prefix=$HOME/meme --enable-build-libxml2 --enable-build-libxslt && make && make test && make install)
        """