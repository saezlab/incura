rule generateBackground:
    input: 
        'data/promoters.fa'
    output:
        'data/background.txt'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        fasta-get-markov < {input} > {output}
        """