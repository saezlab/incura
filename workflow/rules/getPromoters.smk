rule extractPromoters:
    input:
        genome='data/genome.fa',
        annot='data/annot.gtf'
    output:
        db='data/gff.db',
        promoters='data/promoters.tsv'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        echo "Extracting promoters..."
        get_promoter create -g {input.annot} && mv gff.db data/
        get_promoter extract -l 2000 -u 500 -f {input.genome} -g {output.db} -o {output.promoters}
        sed -E 's/("([^"]*)")?,/\2\t/g' promoters.csv > promoters.tsv
        rm data/promoters.csv
        """