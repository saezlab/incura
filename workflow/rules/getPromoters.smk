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



rule formatPromoters:




    shell:
    """
    echo "Formatting promoters..."
    awk -F, '{print $2","$3","$4","$5","$1","$6}' promoters.csv > promoters_formatted.csv
    sed -e 's/^/chr/' -i promoters_formatted.csv 

    cat annot.gtf | awk 'BEGIN{FS="\t"}{split($9,a,";"); if($3~"gene") print a[1]"\t"a[3]}' | sed 's/gene_id "//' | sed 's/gene_name "//' | sed 's/"//g' > ids2names.txt

    
    """

    awk 'NR==FNR {id[$1]=$2; next} {if ($1 in id) $1=id[$1]; print}' ids2names.sorted.txt promoters.sorted.tsv > promoters.final.tsv