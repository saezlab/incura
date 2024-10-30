rule extractPromoters:
    input:
        genome='data/genome.fa',
        annot='data/annot.gtf'
    output:
        db='data/gff.db',
        promoters='data/promoters.csv'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        get_promoter create -g {input.annot} && mv gff.db data/
        get_promoter extract -l 2000 -u 500 -f {input.genome} -g {output.db} -o {output.promoters}
        """


rule formatPromoters:




    shell:
    """
    awk -F, '{print $2","$3","$4","$5","$1","$6}' promoters.csv > promoters_formatted.csv
    sed -e 's/^/chr/' -i promoters_formatted.csv 
    """