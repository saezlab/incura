rule generateBackground:
    input: 
        'data/promoters.fa'
    output:
        'data/background.txt'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        export PATH=$HOME/meme/bin:$HOME/meme/libexec/meme-5.5.7:$PATH
        fasta-get-markov < {input} > {output}
        """