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
        echo "Extracting promoters..."
        get_promoter create -g {input.annot} && mv gff.db data/
        get_promoter extract -l 2000 -u 500 -f {input.genome} -g {output.db} -o {output.promoters}
        """

rule processPromoters:
    input:
        promoters="promoters.csv",
        annot="annot.gtf",
        DEGS="sharedDEGs_mm10.txt"
    output:
        ids2names=temp('ids2names.sorted.txt'),
        promoters=temp('promoters.formatted.tsv')
    shell:
        """
        echo "Retreiving gene names..."
        cat annot.gtf | awk 'BEGIN{FS="\t"}{split($9,a,";"); if($3~"gene") print a[1]"\t"a[3]}' | sed 's/gene_id "//' | sed 's/gene_name "//' | sed 's/"//g' > ids2names.txt
        sort ids2names.txt > {output.ids2names}

        echo "Sorting promoters..."
        tail -n +2 {input.promoters} > promoters.cleaned.csv
        sort promoters.cleaned.csv > promoters.sorted.csv
        echo "Converting promoters..."
        sed -E 's/("([^"]*)")?,/\2\t/g' promoters.sorted.csv > promoters.sorted.tsv

        echo "Assigning gene names..."
        awk 'NR==FNR {id[$1]=$2; next} {if ($1 in id) $1=id[$1]; print}' ids2names.sorted.txt promoters.sorted.tsv > promoters.final.tsv

        echo "Filtering promoters..."
        grep -Ff sharedDEGs_mm10.txt promoters.final.tsv > promoters.final.DE.tsv

        echo "Formatting promoters..."
        awk -F' ' 'BEGIN {OFS=" "} {print $2, $3, $4, $5, $1, $6}' promoters.final.DE.tsv > promoters.formatted.tsv
        sed -e 's/^/chr/' -i promoters.formatted.tsv

        echo "Done."
        """

rule createFasta:
    input:
        tsv="promoters.formatted.tsv",
    output:
        fasta="promoters.fa"
    shell:
        """
        echo "Creating FASTA file..."
        awk -F' ' 'NR>1 {print ">"$1":"$2"-"$3"("$4")_"$5"\n"$6}' {input.tsv} > {output.fasta}
        """