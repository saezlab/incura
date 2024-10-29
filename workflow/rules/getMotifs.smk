rule extractMotifs:
    input: 
    output:
        index='software/meme-5.5.7.tar.gz'
    singularity:
        'workflow/envs/InCURA.sif'
    params:
        organism='Hsapiens'
    shell:
        """
        Rscript workflow/scripts/getMotifs.R \
        {input.TFs} \
        {params.organism} \

        """