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

rule runFIMO:
    input:
        background='data/background.txt',
        motifs='data/motifs.meme',
        promoters='data/promoters.fa'
    output:
        'data/fimo/fimo.tsv'
    singularity:
        'workflow/envs/InCURA.sif'
    threads: 30
    shell:
        """
        fimo --oc data/fimo --verbosity 1 --thresh 1e-5 --bgfile {input.background} {input.motifs} {input.promoters}
        """